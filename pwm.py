#!/usr/bin/python3
import importlib.util
import os
import sys
import argparse
import shutil
import random
import json
import shutil
import subprocess

home = os.path.expanduser("~")
walls_dir = os.environ["WALLPAPERS"]
fav_dir = walls_dir + "/favorites/"
colors_path = home + "/.cache/wal/colors.json"
theme_dir = home + "/scripts/pywal/savedThemes/"
sxiv = False

def reload_sig():
    pids = list(subprocess.check_output(["pidof", "st"]).decode().split())
    for pid in pids:
        subprocess.call(["kill", "-s", "USR1", pid])

def get_wall_name(theme_path=colors_path):
  with open(theme_path) as f:
    theme = json.load(f)
    wallName = (theme["wallpaper"].split("/")[-1].split(".")[0])
    return wallName

def get_wall_path(theme_path=colors_path):
  with open(theme_path) as f:
    theme = json.load(f)
    wall_name = theme["wallpaper"]
    return wall_name

def update_settings(name="", backend = ""):
  if not backend == "":
    pass
  if not name == "":
    pass
    

def backend(fav_dir=fav_dir):
  backends = ['wal'] 
  if importlib.util.find_spec('haishoku'):
    backends.append('haishoku')
  if importlib.util.find_spec('colorz'):
    backends.append('colorz')
  if shutil.which('schemer2'):
    backends.append('schemer2')
  if shutil.which('colortheif'):
    backends.append('colortheir')
  choice = dmenu_prompt(backends,"Backend")
  print(get_wall_path())
  load_theme(get_wall_path(), ['--backend',choice])
  #subprocess.call("wal -i " + get_wall_path() + " --backend " + choice,shell=True)

def save_theme(name,colors_path = colors_path,dest = fav_dir):
  curr_wall = get_wall_path()
  curr_wall_fname = curr_wall.split("/")[-1]
  curr_wall_name = curr_wall_fname.split(".")[-2]
  if curr_wall_fname in os.listdir(fav_dir):
    subprocess.call(["mv",curr_wall, curr_wall.replace(curr_wall_name,name) ])
  else: 
    curr_path = dest+curr_wall_fname.replace(curr_wall_name, name)
    subprocess.call(["cp", curr_wall, curr_path])
    colors_data = None
    with open(colors_path,"r") as colorsjson:
      colors_data = json.load(colorsjson)
    with open(colors_path,"w") as colorsjson:
      colors_data["wallpaper"] = curr_path
      json.dump(colors_data, colorsjson)
  

  print("Saved theme as " + name + " in " + os.path.abspath(dest))

#def sxiv_load_saved(path = theme_dir):
#    themes = os.listdir(theme_dir)
#    wall_paths = {}
#    for theme in themes:
#        wall_paths[os.path.expanduser(get_wall_path(theme_path=theme_dir+theme))] = theme
#    selection = (subprocess.check_output(["sxiv", "-P"] + list(wall_paths.keys()))).decode("utf-8").replace("\n","")
#    load_theme(wall_paths[selection].replace(".json",""))

def load_theme(path,args = []):
  if os.path.isdir(path) and sxiv:
    path = subprocess.check_output(["sxiv", "-b", "-P"] + [path])
    path = path.decode('utf-8').replace("\n","")
  subprocess.call(["wal", "-i", path]+ args)
  reload_sig()

def load_menu(path=walls_dir):
  if os.path.isdir(path):
    path = get_wall_dirs(path)
    load_menu(path)
  else:
    load_theme(path)
  

def load_random_saved(folder):
  theme = random.choice(os.listdir(path)).replace(".json", "")
  load_theme(theme)

def random_wal():
  pictures = []
  for dirpaths, dirs, files in os.walk(wallDir):
    for file in files:
        pictures.append(dirpaths+"/"+file)
  picture = random.choice(pictures)
  os.system("wal -i " + '"' + picture + '"')
  os.system("wal -R ")
  reload_sig()

def set_sxiv():
  global sxiv
  if sxiv:
    sxiv = False
  else:
    sxiv = True
  main_menu()


def get_wall_dirs(walls_dir=walls_dir):
  wall_dirs={wall_subdir:walls_dir +"/"+ wall_subdir for wall_subdir in os.listdir(walls_dir)}
  wall_dirs['Any'] =  walls_dir
  options = list(wall_dirs.keys())
  choice = dmenu_prompt(options,"Folder")
  if choice == "Any":
    del wall_dirs['Any']
    return random.choice(list(wall_dirs.values()))
  else:
    return wall_dirs[choice]
    

def random_menu():
  load_theme(get_wall_dirs())

def dmenu_prompt(dm_items, title, key_mode = False): 
  flags = "" 
  if dm_items == "":
    items = ""
  elif type(list(dm_items)[0]) is tuple:
    items =  '\n'.join([option[0] for option in dm_items])
  else:
    items =  '\n'.join([option for option in dm_items])
  if key_mode:
    flags = "-k"
  choice = subprocess.check_output("echo \'"+ items + "\' | dmenu -i -h 31 -p \"" + title + "\" " + flags, shell=True).decode('utf-8')
  return choice.replace('\n',"")

def main_menu():
  options = {"r": ("r:[r]andom",random_menu),
             "s": ("s:[s]xiv mode", set_sxiv),
             "l": ("l:[l]load", load_menu),
             "f": ("f:[f]avorite", lambda : save_theme(dmenu_prompt("", "Name")) ),
             "b": ("b:[b]ackend", lambda : backend() )
            }
  choice = dmenu_prompt(options.values(), "Wal Menu", key_mode = True)
  if choice == "":
    exit()
  options[choice][1]()

parser = argparse.ArgumentParser()
parser.add_argument("-r", action="store_true", help="picks a random walpaper")
parser.add_argument("-rs", action="store_true", help="picks a random saved theme")
parser.add_argument("-s", const=get_wall_name(), action='store', nargs='?', required=False, help="save scheme")
parser.add_argument("-l", help="Load a theme")
parser.add_argument("-c", action="store_true", help="Choose a saved theme with sxiv")
parser.add_argument("-m", action="store_true", help="Open the dmenu prompt")
args = parser.parse_args()

if args.m:
    main_menu()

if args.r:
  random_wal()
if args.rs:
  load_random_saved()
if args.s:
  save_theme(args.s)
if args.l:
  load_theme(args.l)
if args.c:
  sxiv_load_saved()
