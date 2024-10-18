#!bin/bash/
for file in "$1"/*; do
  if [ -f "$file" ]; then
    lower_case_file=$(echo "$file" | tr '[:upper:]' '[:lower:]')
    if [ "$file" != "$lower_case_file" ]; then
      mv "$file" "$lower_case_file"
      echo "готово: $file -> $lower_case_file"
    fi
  fi
done
