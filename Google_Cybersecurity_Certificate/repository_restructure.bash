#! /bin/bash

# This script is used to restructure the repository.
# This script runs agains every course directory to:
  # Set `Introductions.md`` files as the course directory `readme.md`` for github display
  # Create dedicated module directories (instead fo files) for each course module for better organization
  # Place each coorelated module notes .md file as `readme.md` inside the module directory for github display

# This script is not idempotent, so be careful when running it multiple times.
# This script is not tested on all courses, so be careful when running it on other courses.

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Loop through each course directory
for course_dir in ./*; do
  # Check if the course directory is a directory
  if [ ! -d "$course_dir" ]; then
    echo "Skipping $course_dir, not a directory."
    continue
  fi

  # Change to the course directory
  echo "$course_dir";
  cd "$course_dir";
  echo "";

  if [ -f "Introduction.md" ]; then
    echo "$course_dir Introduction file exists, mograting to readme.";
    mv "Introduction.md" "readme.md";
  else
    echo "$course_dir Introduction file does not exist, creating.";
    touch readme.md;
  fi
  echo "";

  if [ -f "Glossary.md" ]; then
    echo "$course_dir Glossary file exists.";
  else
    # Create a new Glossary.md file
    echo "$course_dir Glossary file does not exist, creating.";
    touch Glossary.md;
  fi
  echo "";


  for num in `seq 1 4`; do
    echo "Module $num";

    # Check if the module directory exists
    if [ -d "Module_$num" ]; then
      echo "Module $num directory exists.";
    else
      # Create a new directory for the module
      echo "Module $num directory does not exist, creating.";
      mkdir -p "Module_$num";
    fi


    # Check if module notes exists
    if [ -f "Module_$num.md" ]; then
      echo "Moving Module $num notes file into directory";
      mv "Module_$num".md "Module_$num"/readme.md;
    else
      echo "Module $num notes file does not exist, creating";
      touch "Module_$num"/readme.md;
    fi
    echo "";
  done


  # Return to program directory for cleanup
  cd ..;
  echo "----------------------------------------";
done