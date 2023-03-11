#!/usr/bin/env nix-shell
#! nix-shell -i "bash -i" -p gitMinimal gnupg
# shellcheck shell=bash

set -euo pipefail

# returns 0 if the repository has been updated, 1 otherwise
update_repo () {
	current_commit=$(git rev-parse @)
	if ! git diff-index --quiet @; then
		git stash --quiet
		git pull --ff-only --quiet
		git stash pop --quiet
	else
		git pull --ff-only --quiet
	fi
	new_commit=$(git rev-parse @)
	if [ "$current_commit" = "$new_commit" ]; then
		return 1
	else
		return 0
	fi
}

mkdir -p "$HOME/.config/nix/"
echo 'experimental-features = nix-command flakes' > "$HOME/.config/nix/nix.conf"

mkdir -p "$HOME/code/nix-config"
pushd "$HOME/code/nix-config/" > /dev/null
if [ ! -e "$HOME/code/nix-config/.git" ]; then
	echo '>setting up nix-config'
	git clone -q https://github.com/raindev/nix-config.git \
		"$HOME/code/nix-config/"
	git remote set-url origin git@github.com:raindev/nix-config.git
else
	if update_repo; then
		echo '>restarting the script after an update'
		exec "$HOME/code/nix-config/configure"
	fi
fi

need_home_manager=false
need_darwin=false
if [[ "$OSTYPE" == linux* ]]; then
	if [ -e /etc/NIXOS ]; then
		nixos_desktop_hosts=(xps13 black)
		nixos_server_hosts=(pi4 netcup)
		if [[ ${nixos_desktop_hosts[*]} =~ $(hostname) ]]; then
			echo -e 'Configuring NixOS desktop\n'
			flake_lock_args=(
				--update-input nixpkgs
				--update-input nixos-hardware
				--update-input home-manager
				--commit-lock-file --commit-lockfile-summary
				'Update nixpkgs, nixos-hardware, home-manager')
		elif [[ ${nixos_server_hosts[*]} =~ $(hostname) ]]; then
			echo -e 'Configuring NixOS server\n'
			flake_lock_args=(
				--update-input nixpkgs-small
				--update-input home-manager
				--commit-lock-file --commit-lockfile-summary
				'Update nixpkgs-small, home-manager')
		else
			echo 'Unrecognized NixOS host'
			exit 1
		fi
		nix_apply='sudo nixos-rebuild switch --flake .'
	else
		echo -e 'Configuring generic Linux\n'
		need_home_manager=true
		flake_lock_args=(
			--update-input nixpkgs
			--update-input home-manager
			--commit-lock-file --commit-lockfile-summary
			'Update nixpkgs, home-manager')
		nix_apply='home-manager switch -b backup --flake .#raindev'
	fi
elif [[ "$OSTYPE" == darwin* ]]; then
	echo -e ' Thinking differently\n'

	echo ">installing updates"
	sudo softwareupdate --install --recommended

	if ! command -v brew > /dev/null ; then
		echo '>installing Homebrew'
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		[ -e /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
		[ -e /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
	fi
	need_darwin=true
	flake_lock_args=(
		--update-input darwin
		--update-input nixpkgs
		--update-input home-manager
		--commit-lock-file --commit-lockfile-summary
		'Update darwin, nixpkgs, home-manager')
	nix_apply='darwin-rebuild switch --flake .'
else
	echo 'Unrecognized or unsupported system'
	exit 1
fi

if [ $need_home_manager = true ] && ! command -v home-manager > /dev/null; then
	echo '>installing Home Manager'
	nix run .#homeConfigurations.raindev.activationPackage
fi
if [ $need_darwin = true ] && ! command -v darwin-rebuild > /dev/null ; then
	echo '>installing nix-darwin'
	nix build .#darwinConfigurations."$(hostname)".system
	./result/sw/bin/darwin-rebuild switch --flake .
fi
echo '>building nix-config'
$nix_apply

if ! gpg --list-key 'Andrew Barchuk' > /dev/null; then
	echo '>setting up GPG'
	echo 'Insert the smartcard'
	read -r
	echo 'Fetch the public key'
	gpg --edit-card
	echo 'Set key trust level'
	gpg --edit-key andrew@raindev.io
	SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
	export SSH_AUTH_SOCK
fi

echo '>updating dependencies'
nix flake lock "${flake_lock_args[@]}"
$nix_apply
git push --quiet

if command -v rustup > /dev/null ; then
	echo '>upgrading Rust'
	rustup upgrade
fi

echo '>setting up Neovim'
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

echo '>setting up scripts'
if [ ! -e "$HOME/code/scripts" ]; then
	git clone -q git@github.com:raindev/scripts.git \
		"$HOME/code/scripts"
fi
(cd "$HOME/code/scripts/" && (update_repo || true))

if [ ! -e "$HOME/.password-store" ]; then
	echo '>setting up pass'
	git clone -q git@github.com:raindev/passwords.git\
		"$HOME/.password-store"
	pass git init
fi
echo '>updating password store'
pass git pull --rebase --quiet
pass git push --quiet

echo '>ensuring symlinks exist'
[ -e "$HOME/org" ] || \
	ln -s "$HOME/notes/org" "$HOME/org"
[ -e "$HOME/cs" ] || \
	ln -s "$HOME/notes/cheatsheets" "$HOME/cs"

echo -e "\nAll done. Enjoy your $(date +%A)!"
