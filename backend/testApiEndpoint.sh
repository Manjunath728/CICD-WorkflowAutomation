#!/bin/bash

# Function to display usage instructions
function display_help {
    echo "Usage: $0 -u <base_url> [--auto]"
    echo "Options:"
    echo "  -u <base_url>   Specify the base URL of the API"
    echo "  --auto          Automatically check all endpoints using sample data"
    exit 1
}

# Function to check if curl is installed
function check_curl {
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is not installed. Please install curl before running this script."
        exit 1
    fi
}

# Function to check if base URL is provided
function check_base_url {
    if [ -z "$base_url" ]; then
        echo "Error: Base URL not provided."
        display_help
    fi
}

# Function to perform health check
function health_check {
    echo "Performing health check..."
    curl -s "$base_url/"
}

# Function to get person by ID
function get_person_by_id {
    curl -s "$base_url/api/person/$1"
}

# Function to get list of all persons
function get_all_persons {
    curl -s "$base_url/api/person"
}

# Function to add person
function add_person {
    curl -s -X POST -d "{\"name\":\"$1\",\"email\":\"$2\"}" -H "Content-Type: application/json" "$base_url/api/person"
}

# Function to update person
function update_person {
    curl -s -X PUT -d "{\"name\":\"$2\",\"email\":\"$3\"}" -H "Content-Type: application/json" "$base_url/api/person/$1"
}

# Function to delete person
function delete_person {
    curl -s -X DELETE "$base_url/api/person/$1"
}

# Function to check all endpoints using sample data
function check_all_endpoints {
    echo "Checking all endpoints using sample data..."
    
    # Perform health check
    health_check

    # Delete all entries
    echo "Deleting all entries..."
    person_ids=$(get_all_persons | jq -r '.[].id')
    for id in $person_ids; do
        delete_person $id 
    done
    echo "Done"

    # Add sample person
    echo "Adding sample person..."
    add_person "John Doe" "john@example.com" 
    echo "Done"
    # Gel all persons
    echo "Get all sample person..."
    get_all_persons 
    echo "Done"
    # Update sample person
    echo "Updating sample person..."
    update_person 1 "merry" "merry@example.com" 
    echo "Done" 
    # Gel all persons
    echo "Get all sample person..."
    get_all_persons 
    echo "Done"
    # Delete sample person
    echo "Deleting sample person..."
    delete_person 1 
    echo "Done"

    echo "All endpoints checked."
}

# Main script
check_curl

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -u)
            base_url="$2"
            shift
            ;;
        --auto)
            auto=true
            ;;
        --help)
            display_help
            ;;
        *)
            echo "Error: Invalid option"
            display_help
            ;;
    esac
    shift
done

check_base_url

# Auto mode: Check all endpoints using sample data
if [ "$auto" = true ]; then
    check_all_endpoints
    exit 0
fi

# Menu-driven interface
while true; do
    echo "Menu:"
    echo "1. Health Check"
    echo "2. Get Person by ID"
    echo "3. Get List of All Persons"
    echo "4. Add Person"
    echo "5. Update Person"
    echo "6. Delete Person"
    echo "7. Auto "
    echo "8. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            health_check
            ;;
        2)
            read -p "Enter person ID: " person_id
            get_person_by_id $person_id
            ;;
        3)
            get_all_persons
            ;;
        4)
            read -p "Enter person name: " person_name
            read -p "Enter person email: " person_email
            add_person "$person_name" "$person_email"
            ;;
        5)
            read -p "Enter person ID to update: " person_id
            read -p "Enter updated name: " updated_name
            read -p "Enter updated email: " updated_email
            update_person $person_id "$updated_name" "$updated_email"
            ;;
        6)
            read -p "Enter person ID to delete: " person_id
            delete_person $person_id
            ;;
        7)
            check_all_endpoints
            ;;
        8)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 7."
            ;;
    esac
done
