#!/bin/bash

if hash R 2>/dev/null
then
    echo "R install found at `which R`"
else
    echo "Installing R"
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
    apt-get update
    yes | apt-get install r-base
fi

echo "Installing packages"
# install packages
R -e "install.packages('ggplot2')"
R -e "install.packages('ggthemes')"
R -e "install.packages('reshape2')"
R -e "install.packages('dplyr2')"
R -e "install.packages('grid')"
R -e "install.packages('viridis')"
R -e "install.packages('pBrackets')"

