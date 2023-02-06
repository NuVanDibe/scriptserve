#!/bin/sh

src_dir="/etc/scriptserve/scripts" # the directory to scan for .sh files
dst_dir="/srv/scripts" # the directory to copy the contents to
nginx_conf="/etc/nginx/nginx.conf" # the location of the Nginx configuration file
new_nginx_conf="$nginx_conf.new" # the location of the new Nginx configuration file
interval=60 # the interval at which to rescan the .sh files, in seconds
index_dir="/srv/scriptserve" # the directory to put the index file

# todo: find a better way to filter out plain text files

# function to generate the index file
generate_index() {
  src_dir="/etc/scriptserve/scripts" # the directory to scan for script files
  index_file="$index_dir/index" # the location of the index file

  # start a new index file
  echo "The scriptserve index! Type \"curl [scriptname].script\" to get one." > "$index_file"

  for file in "$src_dir"/*
  do
    filename="${file##*/}" # extract the file name
    extension="${filename##*.}" # extract the extension
    description="" # initialize the description
    shebang="" # initialize the shebang

    # check if the second line starts with "# description" or ":: description:"
    while read -r line
    do
      if [ "$description" = "" ]; then
        case "$(echo "$line" | tr '[:upper:]' '[:lower:]')" in
          "# description"*|"# description:"*|":: description"*|":: description:")
            description="${line#\# description:}"
            description="${description#:: description:}"
            description="$(echo "$description" | sed 's/^[ \t]*//')"
            ;;
        esac
      fi
      if [ "$shebang" = "" ]; then
        case "$line" in
          "#!"*)
            shebang="$line"
            ;;
        esac
      fi
    done < "$file"

    # add the filename, extension, shebang, and description to the index file

    echo "" >> "$index_file"

    echo -e "${filename%.*} ($extension)" >> "$index_file"
    if [ "$shebang" != "" ]; then
      echo "  $shebang" >> "$index_file"
    fi
    if [ "$description" != "" ]; then
      echo "  $description" >> "$index_file"
    fi
  done
}


# function to rescan the script files
rescan() {
  # delete any directories for .sh files that no longer exist
  for dir in $(ls -d "$dst_dir"/*/)
  do
    dirname="${dir##*/}" # extract the directory name
    file="$src_dir/$dirname.sh" # derive the .sh file from the directory name

    # if the .sh file doesn't exist, remove the directory
    if [ ! -f "$file" ]; then
      rm -rf "$dir" # remove the directory
    fi
  done

  # start a new Nginx configuration file
  nginx_header="events {}
  http {
    server {
      listen 80;
      server_name script;
      root ${index_dir}/;
      index index;
    }"
  echo "$nginx_header" >> "$new_nginx_conf"

  for file in "$src_dir"/*
  do
    if [ "$(head -c 512 "$file")" != "" ]; then # quick and dirty check to see if it's plain text
      filename="${file##*/}" # extract the file name
      dir="$dst_dir/${filename%.*}" # derive the destination directory from the file name
      mkdir -p "$dir/www" # create the destination directory if it doesn't exist
      cp "$file" "$dir/www/index.html" # copy the contents of the .sh file to the index.html file

      # add a new server block to the new Nginx configuration file
      server_block="  server {
      listen 80;
      server_name ${filename%.*}.script;
      root ${dst_dir}/${filename%.*}/www/;
      index index.html;
    }"
      echo "$server_block" >> "$new_nginx_conf"
    fi
  done

  # finish the new Nginx configuration file
  echo "}" >> "$new_nginx_conf"

  # replace the original Nginx configuration file with the new one
  mv "$new_nginx_conf" "$nginx_conf"

  # reload Nginx to pick up the changes
  nginx -s reload
}

# create the index root if it doesn't exist
mkdir -p $index_dir

# run the rescan function when the script starts
rescan
generate_index

# check if Nginx is running, and start it if it's not
if ! pgrep nginx > /dev/null; then
  nginx
fi

# run the rescan function periodically
while true
do
  sleep "$interval"
  rescan
  generate_index
  nginx -s reload
done
