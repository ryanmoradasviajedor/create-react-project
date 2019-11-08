#!/usr/bin/env bash
# This script is expected be run on Mac OSX.

# Color code definitions for printing messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color


###############################################################################
# Check requirements
###############################################################################
# Check .env file exists
if [[ ! -f .env ]]; then
    echo -e "${RED}Missing .env file. Aborting.${NC} Create .env referring '.env.example.dist'."
    exit 1
fi

# Load .env
export $(cat .env | grep -v '^#' | xargs)

APP_DIR=${WEB_APP_DIR}/${APP_NAME}

# Confirm install directory
echo "New application source code will be generated at: "
echo -e "    ${CYAN}${APP_DIR}${NC}"
read -p "Is this OK? [y/N]" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]];then
    echo -e "Not OK. Exiting..."
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Stop, if the directory already exists
if [[ -d "${APP_DIR}" ]]; then
    echo "Directory '${APP_DIR}' already exists. Stop creating project."
    exit 1
fi

# Let script stop on command error
set -e

###############################################################################
# Install bare React
###############################################################################
echo -e "Creating React application project ${GREEN}${APP_NAME}${NC} in"
echo -e "  ${CYAN}${APP_DIR}${NC}..."

set -x

# Workaround to make composer faster
composer config --global repo.packagist composer https://packagist.org

# Install bare React
npx create-react-app $APP_DIR

cd $APP_DIR

echo "You successfully created a new react application!!!"
echo -e "Inside this directory /Users/ryan/development/react-projects/${GREEN}${APP_NAME}${NC}"
read -p "DO you want to start the development server? [y/N]" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]];then
    echo -e "Happy hacking!"
    echo -e "You can run several commands:"
    echo -e " "
    echo -e "${CYAN}npm start${NC}"
    echo -e "   Starts the development server."
    echo -e " "
    echo -e "${CYAN}npm run build${NC}"
    echo -e "   Bundles the app into static files for production."
    echo -e " "
    echo -e "${CYAN}npm test${NC}"
    echo -e "   Starts the test runner."
    echo -e " "
    echo -e "${CYAN}npm run reject${NC}"
    echo -e "   Removes this tool and copies build dependencies, configuration files"
    echo -e "   and scripts into the app directory. If you do this, you can’t go back!"
    echo -e " "
    echo -e "We suggest that you begin by typing:"
    echo -e " "
    echo -e "${CYAN}cd${NC} ${CYAN}/Users/ryan/development/react-projects/new-react-project${NC}"
    echo -e "${CYAN}npm start${NC}"
    exit 1
fi

npm start