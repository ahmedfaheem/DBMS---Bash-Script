#/usr/bin/env bash


createDB(){
   name=$(zenity --entry --title="Create Database" --text="Enter the name of the database" --width=400)

   if [ -z "$name" ]; then
      zenity --error --text="Database name cannot be empty!" --width=300
      return
   else
      if [ -d "$name" ]; then
         zenity --error --text="Database already exists!" --width=300
         return
      else
         mkdir "$name"
         zenity --info --text="Database '$name' created successfully!" --width=300
      fi
   fi
}


listDB(){
    dbs=$(ls -d */ 2>/dev/null | sed 's:/: :g')
   if [ -z "$dbs" ]; then
      zenity --info --text="No databases found!" --width=300
   else
    
      zenity --info --title="List of Databases" --text="$dbs" --width=300
   fi
}

dropDB(){

    name=$(zenity --entry --title="Drop Database" --text="Enter name of the database to drop" --width=400)
    if [ -z "$name" ]; then
        zenity --error --text="Database name cannot be empty!" --width=300
        return
    else
        if [ -d "$name" ]; then
            rm -r "$name"
            zenity --info --text="Database $name dropped successfully!" --width=300
        else
            zenity --error --text="Database $name does not exist!" --width=300
            return
        fi
    fi
}

connectDB(){
        name=$(zenity --entry --title="Connect Database" --text="Enter name of the database to connect" --width=400)
    if [ -z "$name" ]; then
        zenity --error --text="Database name cannot be empty!" --width=300
        return
    else
        if [ -d "$name" ]; then
            cd "$name"
            zenity --info --text="Connected to database $name" --width=300
            tableOperationsMenu
            cd ..
        else
            zenity --error --text="Database $name does not exist!" --width=300
            return
        fi
    fi
}



#-------------------------- DB Functions ----------------------------------


create_table() {
    
   tableName=$(zenity --entry --title="Create Table" --text="Enter name of the table to create");
   if [ -z "$tableName" ]; then
           zenity --error --text="Table name cannot be empty!" --width=300
       return
    fi

    if [ -f "$tableName.meta" ];then
               zenity --error --text="Table Exist Before" --width=300
               return
     fi



     colNums=$(zenity --entry --title="Create Table" --text="Enter Numbers of Columns")
      [[ $? -ne 0 ]] && return
        if ! [[ "$colNums" =~ ^[1-9][0-9]*$ ]]; then
            zenity --error --text="Please enter a valid positive integer for the number of columns." --width=300
            return
        fi
         echo "NumberOfColumns:$colNums" >> $tableName.meta

     for((i=1;i<=$colNums;i++));do

       colName=$(zenity --entry --title=" Column $i Name" --text="Enter Column Name")
       [[ $? -ne 0 ]] && rm "$tableName.meta" && return

       if [[ -z "$colName" ]];then
        zenity --error --text="Column Must has name" --width=300
       ((i--))
       continue
       fi


       colType=$(zenity --list --title=" Column  $i  Data Type" --text="Enter Data Type of Column  $i " --column="Types" "INT" "STRING")
       [[ $? -ne 0 ]] && rm "$tableName.meta" && return
       isPK=$(zenity --list --title="Is Primary Key?" --text="Select Option"  --column="" "YES" "NO")
       [[ $? -ne 0 ]] && rm "$tableName.meta" && return

      if [[ $isPK == "YES" ]];then
         echo "$colName:$colType:PK" >> $tableName.meta
      else
         echo "$colName:$colType" >> $tableName.meta
      fi
     done
         touch "$tableName.data"
      zenity --info --text="$tableName Table created." --width=300

}
insertIntoTable(){
       # SCRIPT_NAME="$(basename "$0")"
       # SCRIPT_NAME="${SCRIPT_NAME%.*}"
        TABLES=$(ls *.meta 2>/dev/null | sed 's/.meta//')
        if [ -z "$TABLES" ]; then
            zenity --error --text="No tables found! Please create a table first." --width=300
            return
        fi
        choice=$(zenity --list --title="Choose a table" --text="Select a table from database:" --column="Tables"  $TABLES --width=300 --height=200)
        if [ -z "$choice" ]; then
            zenity --error --text="No table selected!" --width=300
            return
        fi
         # Call the insert function for the selected table
          
        declare -i numberOfColumn
        numberOfColumn=$(awk -F: '{print $2}' "$choice.meta" | head -n 1)
        # echo "$colName:$colType:PK" >> $tableName.meta
        for ((i=1;i<=numberOfColumn;i++));do
            colName=$(awk -F: 'NR=='$((i+1))'{print $1}' "$choice.meta")
            colType=$(awk -F: 'NR=='$((i+1))'{print $2}' "$choice.meta")
            isPK=$(awk -F: 'NR=='$((i+1))'{print $3}' "$choice.meta")
            while true; do
                value=$(zenity --entry --title="Insert Into Table" --text="Enter value for column '$colName' (Type: $colType)")
                [[ $? -ne 0 ]] && return
                if [[ -z "$value" ]]; then
                    zenity --error --text="Value cannot be empty!" --width=300
                    continue
                fi
                if [[ "$colType" == "INT" && ! "$value" =~ ^-?[0-9]+$ ]]; then
                    zenity --error --text="Please enter a valid integer for column '$colName'." --width=300
                    continue
                fi
                if [[ "$isPK" == "PK" ]]; then
                    if grep -q "^$value:" "$choice.data"; then
                        zenity --error --text="Primary key value '$value' already exists in column '$colName'." --width=300
                        continue
                    fi
                fi
                echo -n "$value:" >> "$choice.data"
                break
            done
        done
        echo "" >> "$choice.data"
        zenity --info --text="Record inserted successfully into table '$choice'." --width=300
}
selectFromTable(){
        SCRIPT_NAME="$(basename "$0")"
        SCRIPT_NAME="${SCRIPT_NAME%.*}"
        TABLES=$(ls *.meta 2>/dev/null | sed 's/.meta//')
        if [ -z "$TABLES" ]; then
            zenity --error --text="No tables found! Please create a table first." --width=300
            return
        fi
        choice=$(zenity --list --title="Choose a table" --text="Select a table from database:" --column="Tables" $TABLES --width=300 --height=200)
        if [ -z "$choice" ]; then
            zenity --error --text="No table selected!" --width=300
            return
        fi
         value=$(zenity --entry --title="Enter Value you search for " --text="Enter value to search for (leave empty to select all records)")
                [[ $? -ne 0 ]] && return
                if [[ -z "$value" ]]; then
                if [[ ! -s "$choice.data" ]]; then
                        zenity --error --title="Error"  --text="Table '$choice' is empty or does not exist."
                        else
                        column -t -s ':' "$choice.data" | zenity --text-info --title="Table: $choice" --width=500 --height=300
                        fi
                else
                    results=$(grep "$value" "$choice.data")
                    if [[ -z "$results" ]]; then
                        zenity --info --text="No records found with value '$value' in table '$choice'." --width=300
                    else
                        zenity --info --text="Records found with value '$value' in table '$choice':" --width=300
                        echo "$results" | column -t -s ':' | zenity --text-info --title="Search Results" --width=500 --height=300
                    fi

                fi

    
}
deleteFromTable(){
                
        zenity --info --text="Selected Delete From Table Function" --width=300
        SCRIPT_NAME="$(basename "$0")"
        SCRIPT_NAME="${SCRIPT_NAME%.*}"
        TABLES=$(ls *.meta 2>/dev/null | sed 's/.meta//')
        if [ -z "$TABLES" ]; then
            zenity --error --text="No tables found! Please create a table first." --width=300
            return
        fi
        choice=$(zenity --list --title="Choose a table" --text="Select a table from database:" --column="Tables" $TABLES --width=300 --height=200)
        if [ -z "$choice" ]; then
            zenity --error --text="No table selected!" --width=300
            return
        fi
        if [[ ! -s "$choice.data" ]]; then
                        zenity --error --title="Error"  --text="Table '$choice' is empty or does not exist."
                        else
                        column -t -s ':' "$choice.data" | zenity --text-info --title="Table: $choice" --width=500 --height=300
                        fi
         value=$(zenity --entry --title="Enter Value you search for to delete " --text="Enter value to search for deletion (leave empty to delete all records)")
                [[ $? -ne 0 ]] && return
                if [[ -z "$value" ]]; then
                if [[ ! -s "$choice.data" ]]; then
                        zenity --error --title="Error"  --text="Table '$choice' is empty or does not exist."
                        else
                        zenity --question --text="Are you sure you want to delete all records from table '$choice'?" --width=300
                        if [[ $? -eq 0 ]]; then
                        > "$choice.data"
                        zenity --info --text="All records deleted from table '$choice'." --width=300
                        fi
                        fi
                else
                    results=$(grep "$value" "$choice.data")
                    if [[ -z "$results" ]]; then
                        zenity --info --text="No records found with value '$value' in table '$choice'." --width=300
                    else
                        grep -v "$value" "$choice.data" > temp.data && mv temp.data "$choice.data"
                        zenity --info --text="Records with value '$value' deleted from table '$choice'." --width=300
                    fi

                fi
   #taht will delete all records that match the value entered by the user. If the user leaves the input empty, it will delete all records from the selected table.
   #ask if the user want to delete all records if the input is empty

}
updateTable(){

            zenity --info --text="Selected Update Table Function" --width=300
            SCRIPT_NAME="$(basename "$0")"
            SCRIPT_NAME="${SCRIPT_NAME%.*}"
            TABLES=$(ls *.meta 2>/dev/null | sed 's/.meta//')
            if [ -z "$TABLES" ]; then
                zenity --error --text="No tables found! Please create a table first." --width=300
                return
            fi
            choice=$(zenity --list --title="Choose a table" --text="Select a table from database:" --column="Tables" $TABLES --width=300 --height=200)
            if [ -z "$choice" ]; then
                zenity --error --text="No table selected!" --width=300
                return
            fi
            if [[ ! -s "$choice.data" ]]; then
                            zenity --error --title="Error"  --text="Table '$choice' is empty or does not exist."
                            else
                            column -t -s ':' "$choice.data" | zenity --text-info --title="Table: $choice" --width=500 --height=300
                            fi
                value=$(zenity --entry --title="Enter Value you search for to update " --text="Enter value to search for update")
                [[ $? -ne 0 ]] && return
                if [[ -z "$value" ]]; then
                        zenity --error --text="No value entered!" --width=300
                        return
                fi
                
                
                    results=$(grep "$value" "$choice.data")
                    if [[ -z "$results" ]]; then
                        zenity --info --text="No records found with value '$value' in table '$choice'." --width=300
                    else
                    echo "$results" | column -t -s ':' | zenity --text-info --title="Records to be updated" --width=500 --height=300
                        #Ask user for new value    
                        new_value=$(zenity --entry --title="New value" --text="Enter new value to replace '$value'")
                        [[ $? -ne 0 ]] && return

                        if [[ -z "$new_value" ]]; then
                            zenity --error --text="No new value entered!"
                            return
                        fi
                        sed "s/$value/$new_value/g" "$choice.data" > temp.data && mv temp.data "$choice.data"
                                 
                        zenity --info --text="Records updated successfully in table '$choice'." --width=300 
                    fi  

}                 



tableOperationsMenu(){

 while true; do
 choice=$(zenity --list --title="Table Operations" --text="Select an option:" --column="Options"\
   "Create Table" \
   "Insert Into Table" \
   "Select From Table" \
   "Delete From Table" \
   "Update Table" \
   "Back to Main Menu" --width=400 --height=400) || exit

    case $choice in
        "Create Table")
            create_table
            ;;
        "Insert Into Table")
            insertIntoTable
            ;;
        "Select From Table")
            selectFromTable
            ;;
        "Delete From Table")
            deleteFromTable
            ;;
        "Update Table")
            updateTable
            ;;
        "Back to Main Menu")
            return
            ;;
        *)
            zenity --error --text="Invalid option selected!" --width=300
            ;;
    esac
    done;
}

main(){

   while true; do
   choice=$(zenity --list --title="Database Management System" --text="Select an option:" --column="Options" \
   "Create Database" \
   "List Databases" \
   "Drop Database" \
   "Connect to Database" \
   "Exit" --width=400 --height=400) || exit

   case $choice in
      "Create Database")
         createDB
         ;;
      "List Databases")
         listDB
         ;;
      "Drop Database")
         dropDB
         ;;
      "Connect to Database")
         connectDB
         ;;
      "Exit")
         exit 0
         ;;
      *)
         zenity --error --text="Invalid option selected!" --width=300
         ;;
   esac

   done;

}

#calling main function
main