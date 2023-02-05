#!/bin/sh

src_dir="/etc/scriptserve/scripts" # the directory to scan for .sh files
dst_dir="/srv" # the directory to copy the contents to
nginx_conf="/etc/nginx/nginx.conf" # the location of the Nginx configuration file
new_nginx_conf="$nginx_conf.new" # the location of the new Nginx configuration file
interval=60 # the interval at which to rescan the .sh files, in seconds

# function to generate the index file
generate_index() {
  src_dir="/etc/scriptserve/scripts" # the directory to scan for .sh files
  index_file="/srv/index" # the location of the index file

  # start a new index file
  echo "" > "$index_file"

  for file in "$src_dir"/*.sh
  do
    filename="${file##*/}" # extract the file name
    description="" # initialize the description

    # check if the second line starts with "# description"
    while read -r line
    do
      if [ "$description" = "" ]; then
        case "$line" in
          "# description"*|"# DESCRIPTION"*)
            description="${line#\# description}"
            description="$(echo "$description" | sed 's/[\r\t]//g')"
            ;;
        esac
      fi
    done < "$file"

    # add the filename and description to the index file
    echo "" >> "$index_file"
    echo "${filename%.*}" >> "$index_file"
    if [ "$description" != "" ]; then
      echo "$description" >> "$index_file"
    fi
  done
}


# function to rescan the .sh files
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
  echo "events {}" > "$new_nginx_conf"
  echo "http {" >> "$new_nginx_conf"
  echo "  server {" >> "$new_nginx_conf"
  echo "    location / {" >> "$new_nginx_conf"
  echo "      index index;" >> "$new_nginx_conf"
  echo "    }" >> "$new_nginx_conf"
  echo "  }" >> "$new_nginx_conf"

  for file in "$src_dir"/*.sh
  do
    filename="${file##*/}" # extract the file name
    dir="$dst_dir/${filename%.*}" # derive the destination directory from the file name
    mkdir -p "$dir/www" # create the destination directory if it doesn't exist
    cp "$file" "$dir/www/index.html" # copy the contents of the .sh file to the index.html file

    # add a new server block to the new Nginx configuration file
    server_block="  server {
    listen 80;
    server_name ${filename%.*}.script;
    root /srv/${filename%.*}/www/;
    index index.html;
  }"
    echo "$server_block" >> "$new_nginx_conf"
  done

  # finish the new Nginx configuration file
  echo "}" >> "$new_nginx_conf"

  # replace the original Nginx configuration file with the new one
  mv "$new_nginx_conf" "$nginx_conf"

  # reload Nginx to pick up the changes
  nginx -s reload
}

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
