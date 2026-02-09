# Database Management System (DBMS) - Bash Script

A command-line Database Management System built entirely in Bash with a graphical user interface using Zenity dialogs. This lightweight DBMS allows users to create and manage databases and tables through an intuitive GUI.

## Features

### Database Operations
- **Create Database**: Create new databases as directories
- **List Databases**: View all existing databases
- **Drop Database**: Delete databases and their contents
- **Connect to Database**: Connect to a specific database to perform table operations

### Table Operations
- **Create Table**: Define tables with custom columns, data types, and primary keys
- **Insert Into Table**: Add records to tables with validation
- **Select From Table**: Query records by primary key or view all records
- **Delete From Table**: Remove specific records by primary key or clear entire table
- **Update Table**: Modify existing records using primary key lookup

## Prerequisites

- **Bash**: Version 4.0 or higher
- **Zenity**: GUI dialog tool
  ```bash
  # Install on Ubuntu/Debian
  sudo apt-get install zenity
  
  # Install on Fedora/RHEL
  sudo dnf install zenity
  
  # Install on Arch Linux
  sudo pacman -S zenity
  ```

## Installation

1. Clone or download this repository
2. Make the script executable:
   ```bash
   chmod +x DBMS.sh
   ```
3. Run the script:
   ```bash
   ./DBMS.sh
   ```

## Usage

### Starting the Application

Run the script from the terminal:
```bash
./DBMS.sh
```

The main menu will appear with the following options:
- Create Database
- List Databases
- Drop Database
- Connect to Database
- Exit

### Creating a Database

1. Select "Create Database" from the main menu
2. Enter a unique database name
3. The database will be created as a directory

### Working with Tables

1. Connect to a database using "Connect to Database"
2. Enter the database name
3. Access the table operations menu

#### Creating a Table

1. Select "Create Table"
2. Enter table name
3. Specify number of columns
4. For each column, define:
   - Column name
   - Data type (INT or STRING)
   - Primary key status (YES or NO)

#### Inserting Data

1. Select "Insert Into Table"
2. Choose the target table
3. Enter values for each column
4. The system validates:
   - Data types (INT values must be numeric)
   - Primary key uniqueness
   - Empty values are not allowed

#### Querying Data

1. Select "Select From Table"
2. Choose the table to query
3. Options:
   - Leave primary key field empty to view all records
   - Enter a primary key value to search for specific records

#### Updating Records

1. Select "Update Table"
2. Choose the table
3. View current records
4. Enter the primary key of the record to update
5. Enter the current value you want to change
6. Enter the new value

#### Deleting Records

1. Select "Delete From Table"
2. Choose the table
3. View current records
4. Options:
   - Leave primary key field empty to delete all records
   - Enter a specific primary key to delete that record only

## File Structure

```
DBMS - Bash Script/
│
├── DBMS.sh              # Main script file
├── README.md            # Documentation
│
├── [DatabaseName]/      # Database directories (created by user)
│   ├── table1.meta      # Table metadata (structure definition)
│   ├── table1.data      # Table data (actual records)
│   ├── table2.meta
│   └── table2.data
```

### Metadata File Format (.meta)

The `.meta` files store table structure:
```
NumberOfColumns:N
colName1:dataType1:isPK1:colName2:dataType2:isPK2:...
```

Example:
```
NumberOfColumns:3
id:INT:YES:name:STRING:NO:age:INT:NO:
```

### Data File Format (.data)

The `.data` files store table records in colon-separated format:
```
value1:value2:value3:
value1:value2:value3:
```

## Technical Details

### Data Types
- **INT**: Integer values (validated with regex: `^-?[0-9]+$`)
- **STRING**: Text values (no validation)

### Primary Key Constraints
- Only one primary key per table
- Primary key values must be unique
- Required for Update and Delete operations

### Key Functions

- `createDB()`: Creates a new database directory
- `connectDB()`: Changes to database directory and opens table menu
- `create_table()`: Creates table metadata and data files
- `insertIntoTable()`: Adds records with validation
- `selectFromTable()`: Queries records by primary key
- `updateTable()`: Modifies existing records
- `deleteFromTable()`: Removes records from table
- `get_pk_index()`: Helper function to find primary key column index

## Error Handling

The system includes validation for:
- Empty database/table names
- Duplicate database/table names
- Invalid column numbers
- Type validation for INT fields
- Primary key uniqueness
- Empty table operations
- Non-existent primary key values

## Limitations

- Single primary key per table (composite keys not supported)
- Two data types only (INT and STRING)
- No support for NULL values
- No foreign key constraints
- No query language (SQL-like syntax not supported)
- No indexing for performance optimization
- No transaction support

## Future Enhancements

- [ ] Support for more data types (FLOAT, DATE, BOOLEAN)
- [ ] Composite primary keys
- [ ] Foreign key relationships
- [ ] Advanced query filtering (WHERE conditions)
- [ ] Export/Import functionality (CSV, JSON)
- [ ] User authentication and permissions
- [ ] Backup and restore capabilities
- [ ] Transaction support with rollback

## Contributing

Feel free to fork this project and submit pull requests for any improvements.

## Contributors

- **Ahmed Faheem** - [ahmedfaheem499@gmail.com](mailto:ahmedfaheem499@gmail.com)
- **Abdelftah Shkal** - [abdelftahshkal@gmail.com](mailto:abdelftahshkal@gmail.com)

## License

This project is open source and available for educational purposes.

## Author

ITI Labs - Shell Script Project

---

**Note**: This is an educational project demonstrating file-based database management using Bash scripting and Zenity for GUI interactions.
