#!/bin/sh


remove_home(){
	target_subs="$(echo "$1" | sed "s/\//|/g")"
	home_subs="$(echo "$HOME" | sed "s/\//|/g")"
	actual_sub="$(echo "$target_subs" | sed "s/$home_subs//g")"
	fix_sub="$(echo "$actual_sub" | sed "s/|/\//g")"
	echo $fix_sub
}


create_path(){
	source="$1"
	target_dir="$(dirname $2)"
	[ -f "$source" ] && [ ! -d "$target_dir" ] && mkdir -p $target_dir && echo "Made path for:\n$target_dir"
}

revsl(){
	original="$1" target="$2"
	[ -d "$target" ] && return	 
	test -h "$target" && return	 
	mv -- "$original" "$target"
	case "$original" in
	  */*)
	    case "$target" in
	      /*) :;;
	      *) target="$(cd -- "$(dirname -- "$target")" && pwd)/${target##*/}"
	    esac
	esac
	ln -s -- "$target" "$original"
}


to_dotfiles(){
	source="$(realpath -s $1)"
	subs="$(remove_home $source)"
	target=$DOTFILES"/home"$subs	
	echo "$source"
	if [ -d "$source" ];
	then 
		for subpath in "$source"/*;
		do	
			to_dotfiles "$subpath"
			echo $subpath
		done
	fi
	create_path $source $target
	revsl $source $target
	echo "Moved:\n$subs\nTo:\n$target\nAnd replaced with a symlink"
}

for path in "$@";
do
	#source="$(realpath $path)"
	#subs="$(remove_home $source)"
	to_dotfiles "$path"
done
