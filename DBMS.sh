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

#-------------------------- helper functions ----------------------------------
get_pk_index() {
    awk -F: '{
        for (i=1; i<=NF; i+=3) {
            if ($(i+2)=="YES") {
                print (i+2)/3
                exit
            }
        }
    }' "$1.meta"
}

name:type:pk
value


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
         echo -n "$colName:$colType:YES:" >> $tableName.meta
      else
         echo  -n "$colName:$colType:NO:" >> $tableName.meta
      fi

     done
         touch "$tableName.data"
      zenity --info --text="$tableName Table created." --width=300

}
insertIntoTable(){
        zenity --info --text="Selected Insert Into Table Function" --width=300
        TABLES=$(ls *.meta 2>/dev/null | sed 's/.meta//')
        if [ -z "$TABLES" ]; then
            zenity --error --text="No tables found! Please create a table first." --width=300
            return
        fi
        choice=$(zenity --list --title="Choose a table" --text="Select a table from database:" --column="Tables"  $TABLES --width=300 --height=200)
          
        declare -i numberOfColumn
        numberOfColumn=$(awk -F: '{print $2}' "$choice.meta" | head -n 1)
        total_fields=$((numberOfColumn * 3))
        columns_line=$(sed -n '2p' "$choice.meta")
        for ((i=1; i<=total_fields; i+=3)); do
            colName=$(awk -F: -v n=$i '{print $n}' <<< "$columns_line")
            colType=$(awk -F: -v n=$((i+1)) '{print $n}' <<< "$columns_line")
            isPK=$(awk -F: -v n=$((i+2)) '{print $n}' <<< "$columns_line")
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
                if [[ "$isPK" == "YES" ]]; then
                    pk_index=$(get_pk_index "$choice")
                    if awk -F: -v pk="$value" -v idx="$pk_index" '$idx == pk { exit 1 }' "$choice.data"
                    then
                        :
                    else
                    
                        zenity --error --text="Primary key value '$value' already exists!"
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
        zenity --info --text="Selected Select From Table Function" --width=300
        TABLES=$(ls *.meta 2>/dev/null | sed 's/.meta//')
        if [ -z "$TABLES" ]; then
            zenity --error --text="No tables found! Please create a table first." --width=300
            return
        fi
        choice=$(zenity --list --title="Choose a table" --text="Select a table from database:" --column="Tables" $TABLES --width=300 --height=200)
        [[ $? -ne 0 ]] && return
        pk_index=$(get_pk_index "$choice")
            if [[ -z "$pk_index" ]]; then
                zenity --error --text="No Primary Key defined for table '$choice'. Update operation requires a Primary Key." --width=300
                return
            fi  
            pk_value=$(zenity --entry --title="Search by Primary Key" --text="Enter Primary Key value to search for (leave empty to select all records) ")
                [[ $? -ne 0 ]] && return
            if [[ -z "$pk_value" ]]; then
                if [[ ! -s "$choice.data" ]]; then
                        zenity --error --title="Error"  --text="Table '$choice' is empty or does not exist."
                else
                        column -t -s ':' "$choice.data" | zenity --text-info --title="Table: $choice" --width=500 --height=300
                fi
            else
                results=$(awk -F: -v pk="$pk_value" -v idx="$pk_index" '$idx == pk' "$choice.data")
                        if [[ -z "$results" ]]; then
                            zenity --info --text="No records found with Primary Key value '$pk_value' in table '$choice'." --width=300
                            return
                        else
                            zenity --info --text="Records found with Primary Key value '$pk_value' in table '$choice':" --width=300
                            echo "$results" | column -t -s ':' | zenity --text-info --title="Search Results" --width=500 --height=300
                        fi
            fi
    
}
deleteFromTable(){
                
        zenity --info --text="Selected Delete From Table Function" --width=300
        TABLES=$(ls *.meta 2>/dev/null | sed 's/.meta//')
        if [ -z "$TABLES" ]; then
            zenity --error --text="No tables found! Please create a table first." --width=300
            return
        fi
        choice=$(zenity --list --title="Choose a table" --text="Select a table from database:" --column="Tables" $TABLES --width=300 --height=200)
        if [[ ! -s "$choice.data" ]]; then
                        zenity --error --title="Error"  --text="Table '$choice' is empty or does not exist."
                        else
                        column -t -s ':' "$choice.data" | zenity --text-info --title="Table: $choice" --width=500 --height=300
                        fi
        
        pk_index=$(get_pk_index "$choice")

        if [[ -z "$pk_index" ]]; then
            zenity --error --text="No Primary Key defined for table '$choice'."
            return
        fi

        pk_value=$(zenity --entry --title="Delete by Primary Key" --text="Enter Primary Key value to delete (leave empty to delete all records)")
        [[ $? -ne 0 ]] && return
        if [[ -z "$pk_value" ]]; then
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
            results=$(awk -F: -v pk="$pk_value" -v idx="$pk_index" '$idx == pk' "$choice.data")
            if [[ -z "$results" ]]; then
                zenity --info --text="No records found with Primary Key value '$pk_value' in table '$choice'." --width=300
            else
                awk -F: -v pk="$pk_value" -v idx="$pk_index" '$idx != pk' "$choice.data" > temp.data && mv temp.data "$choice.data"           
                zenity --info --text="Record with Primary Key value '$pk_value' deleted from table '$choice'." --width=300
            fi  
        fi
       
}
updateTable(){

            zenity --info --text="Selected Update Table Function" --width=300
            TABLES=$(ls *.meta 2>/dev/null | sed 's/.meta//')
            if [ -z "$TABLES" ]; then
                zenity --error --text="No tables found! Please create a table first." --width=300
                return
            fi
            choice=$(zenity --list --title="Choose a table" --text="Select a table from database:" --column="Tables" $TABLES --width=300 --height=200)
            if [[ ! -s "$choice.data" ]]; then
                            zenity --error --title="Error"  --text="Table '$choice' is empty or does not exist."
                            else
                            column -t -s ':' "$choice.data" | zenity --text-info --title="Table: $choice" --width=500 --height=300
                            fi
            pk_index=$(get_pk_index "$choice")
            if [[ -z "$pk_index" ]]; then
                zenity --error --text="No Primary Key defined for table '$choice'. Update operation requires a Primary Key." --width=300
                return
            fi  
            pk_value=$(zenity --entry --title="Update by Primary Key" --text="Enter Primary Key value to update")
                [[ $? -ne 0 ]] && return
            if [[ -z "$pk_value" ]]; then
                zenity --error --text="Primary Key value cannot be empty for update operation." --width=300
                return
            fi
                results=$(awk -F: -v pk="$pk_value" -v idx="$pk_index" '$idx == pk' "$choice.data")
                        if [[ -z "$results" ]]; then
                            zenity --info --text="No records found with Primary Key value '$pk_value' in table '$choice'." --width=300
                            return
                        else
                            echo "$results" | column -t -s ':' | zenity --text-info --title="Record to be updated" --width=500 --height=300
                             value=$(zenity --entry --title="Enter Value you search for to update " --text="Enter value to search for update")
                             [[ $? -ne 0 ]] && return
                            if [[ -z "$value" ]]; then
                            zenity --error --text="No value entered!" --width=300
                            return
                            fi
                              #Ask user for new value    
                             new_value=$(zenity --entry --title="New value" --text="Enter new value to replace '$value'")
                              [[ $? -ne 0 ]] && return

                             if [[ -z "$new_value" ]]; then
                                 zenity --error --text="No new value entered!"
                                 return
                             fi
                                awk -F: -v OFS=: \
                                    -v pk="$pk_value" \
                                    -v idx="$pk_index" \
                                    -v old="$value" \
                                    -v new="$new_value" '
                                {
                                    if ($idx == pk) {
                                        for (i = 1; i <= NF; i++) {
                                            if ($i == old) {
                                                $i = new
                                            }
                                        }
                                    }
                                    print
                                }' "$choice.data" > temp.data && mv temp.data "$choice.data"
                                 
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