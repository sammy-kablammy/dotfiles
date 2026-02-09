# not really used at the moment but hey it's here

{

	home.username = "sam";
	home.homeDirectory = "/home/sam";
	home.stateVersion = "25.05";
	home.shellAliases = {
		cp="cp --interactive";
		rm="rm --interactive";
		mv="mv --interactive";
	};

	programs.neovim = {
		enable = true;
		vimAlias = true;
		viAlias = true;
	};

	programs.bash.enable = true;
	programs.ripgrep.enable = true;
	programs.fzf.enable = true;
	programs.eza.enable = true;
	programs.tmux.enable = true;

}
