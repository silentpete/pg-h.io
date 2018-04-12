for VAR in $(find . -type f -name "build.sh"); do echo -e "\e[32mINFO building $VAR\e[0m"; $VAR; done;
