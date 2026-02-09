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
      dbs=$(ls -d */ | sed 's:/*$::')
      zenity --list --title="List of Databases" --column="Databases" $dbs --width=300
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
            ## Display database menu here
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

