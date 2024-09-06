const express = require('express');
const path = require('path');
const sql = require('mssql');
const app = express();
const port = process.env.PORT || 3000;

const dbConfig = {
    user: 'BakeryAdmin',
    password: 'cr0ssiant!',
    server: 'bakerymanagementserver.database.windows.net',
    database: 'bakerymanagement',
    options: {
        encrypt: true // For Azure SQL Database
    }
};

// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// For single-page apps, serve index.html for all routes
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});




console.log('Server is starting...');

sql.connect(dbConfig).then(pool => {
    if (pool.connected) {
      console.log('Connected to Azure SQL Server');
    }
  }).catch(err => console.error('Database connection failed:', err));

 

  // GET /vendors: Retrieve all vendors
app.get('/vendors', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const vendors = await pool.request().query('SELECT * FROM Vendor');
        res.json(vendors.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// POST /vendors: Add a new vendor
app.post('/vendors', async (req, res) => {
    const { vendor_name, vendor_address, contact_info } = req.body;
    try {
       const pool = await sql.connect(dbConfig);
       await pool.request()
       .input('vendor_name', sql.VarChar, vendor_name)
       .input('vendor_address', sql.VarChar, vendor_address)
       .input('contact_info', sql.VarChar, contact_info)
       .query('INSERT INTO Vendor (vendor_name, vendor_address, contact_info) VALUES (@vendor_name, @vendor_address, @contact_info)');
   
   res.status(201).send('Vendor added successfully');
} catch (error) {
   res.status(500).send(error.message);
}
});
      

// DELETE /vendors/name/:name: Remove a vendor by name
app.delete('/vendors/name/:name', async (req, res) => {
    const vendor_name = req.params.name;

    if (!vendor_name) {
        return res.status(400).send('Vendor name is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('vendor_name', sql.NVarChar, vendor_name)  // Assuming the vendor_name column is of type NVarChar
            .query('DELETE FROM Vendor WHERE vendor_name = @vendor_name');
        
        if (result.rowsAffected[0] > 0) {
            res.status(200).send('Vendor deleted successfully');
        } else {
            res.status(404).send('Vendor not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// PUT /vendors/:id: Update vendor information
app.put('/vendors/:id', async (req, res) => {
    const vendor_id = req.params.id;
    const { vendor_name, vendor_address, contact_info } = req.body;

    // Start building the SQL query
    let query = 'UPDATE Vendor SET ';
    let parameters = [];

    // Add fields to update based on the request body
    if (vendor_name) {
        query += 'vendor_name = @vendor_name, ';
        parameters.push({ name: 'vendor_name', value: vendor_name });
    }
    if (vendor_address) {
        query += 'vendor_address = @vendor_address, ';
        parameters.push({ name: 'vendor_address', value: vendor_address });
    }
    if (contact_info) {
        query += 'contact_info = @contact_info, ';
        parameters.push({ name: 'contact_info', value: contact_info });
    }

    // Remove the trailing comma and space
    query = query.slice(0, -2);

    // Add the WHERE clause
    query += ' WHERE vendor_id = @vendor_id';
    parameters.push({ name: 'vendor_id', value: vendor_id });

    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();
        parameters.forEach(param => request.input(param.name, sql.VarChar, param.value));
        
        const result = await request.query(query);

        if (result.rowsAffected[0] > 0) {
            res.send('Vendor updated successfully');
        } else {
            res.status(404).send('Vendor not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// GET /vendors/name/:name: Retrieve a specific vendor by name
app.get('/vendors/name/:name', async (req, res) => {
    const vendor_name = req.params.name;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('vendor_name', sql.VarChar, vendor_name)
            .query('SELECT * FROM Vendor WHERE vendor_name = @vendor_name');
        
        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('Vendor not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// POST /users: Add a new user
app.post('/users', async (req, res) => {
    const { username, password, access_level } = req.body;
    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
        .input('username', sql.VarChar, username)
        .input('password', sql.VarChar, password)
        .input('access_level', sql.VarChar,access_level)
        .query('INSERT INTO Users (username,password,access_level) VALUES (@username, @password, @access_level)');

    res.status(201).send('User added successfully');
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// DELETE /users/username/:username: Remove a user by username
app.delete('/users/username/:username', async (req, res) => {
    const username = req.params.username;

    if (!username) {
        return res.status(400).send('Username is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('username', sql.VarChar, username)
            .query('DELETE FROM Users WHERE username = @username');

        if (result.rowsAffected[0] > 0) {
            res.send('User removed');
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// PUT /users/:id/password: Update user password
app.put('/users/:id/password', async (req, res) => {
    const userId = req.params.id;
    const { password } = req.body;

    if (!password) {
        return res.status(400).send('Password is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('password', sql.VarChar, password)  // Assuming password is a VARCHAR
            .input('user_id', sql.Int, userId)
            .query('UPDATE Users SET password = @password WHERE user_id = @user_id');

        if (result.rowsAffected[0] > 0) {
            res.send('Password updated');
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// PUT /users/:id/access-level: Update user access level
app.put('/users/:id/access-level', async (req, res) => {
    const userId = req.params.id;
    const { access_level } = req.body;

    if (access_level === undefined) {
        return res.status(400).send('Access level is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('access_level', sql.VarChar, access_level)  // Adjust sql type if needed
            .input('user_id', sql.Int, userId)
            .query('UPDATE Users SET access_level = @access_level WHERE user_id = @user_id');

        if (result.rowsAffected[0] > 0) {
            res.send('Access level updated');
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// GET /users: Retrieve all users
app.get('/users', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM Users');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// GET /users/username/:username: Retrieve a specific user by username
app.get('/users/username/:username', async (req, res) => {
    const username = req.params.username;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('username', sql.VarChar, username)
            .query('SELECT * FROM Users WHERE username = @username');

        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// POST /login: Authenticate user without hashing (for testing purposes only)
app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('username', sql.VarChar, username)
            .query('SELECT password FROM Users WHERE username = @username');
        
        if (result.recordset.length > 0) {
            const dbPassword = result.recordset[0].password;
            console.log(`Password from DB: ${dbPassword}`); // Log password from DB for verification

            // Direct comparison of plain-text passwords (for testing purposes)
            if (password === dbPassword) {
                res.send('Authentication successful');
            } else {
                res.status(401).send('Invalid credentials');
            }
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


//const bcrypt = require('bcrypt');

// POST /login: Authenticate user
//app.post('/login', async (req, res) => {
  //  const { username, password } = req.body;

    //try {
      //  const pool = await sql.connect(dbConfig);
        //const result = await pool.request()
          //  .input('username', sql.VarChar, username)
            //.query('SELECT password FROM Users WHERE username = @username');
        
        //if (result.recordset.length > 0) {
          //  const hashedPassword = result.recordset[0].password;
            //console.log(`Hashed password from DB: ${hashedPassword}`); // Log hashed password

            //const isMatch = await bcrypt.compare(password, hashedPassword);
            
            //if (isMatch) {
              //  res.send('Authentication successful');
            //} else {
              //  res.status(401).send('Invalid credentials');
            //}
       // } else {
         //   res.status(404).send('User not found');
        //}
    //} catch (error) {
      //  res.status(500).send(error.message);
    //}
//});



// Add Employee
app.post('/api/employees', async (req, res) => {
    const { first_name, last_name, job_title, date_hired, pay_rate, address, phone_number } = req.body;

    // Validate required fields
    if (!first_name || !last_name || !job_title || !date_hired || !pay_rate || !address || !phone_number) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('first_name', sql.VarChar, first_name)
            .input('last_name', sql.VarChar, last_name)
            .input('job_title', sql.VarChar, job_title)
            .input('date_hired', sql.Date, date_hired)
            .input('pay_rate', sql.Decimal, pay_rate)  // Adjust SQL type if needed
            .input('address', sql.VarChar, address)
            .input('phone_number', sql.VarChar, phone_number)
            .query(`
                INSERT INTO Employee (first_name, last_name, job_title, date_hired, pay_rate, address, phone_number) 
                VALUES (@first_name, @last_name, @job_title, @date_hired, @pay_rate, @address, @phone_number)
            `);

        res.status(201).json({ message: 'Employee added' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// Remove Employee
app.delete('/api/employees/:employee_id', async (req, res) => {
    const employeeId = req.params.employee_id;

    if (!employeeId) {
        return res.status(400).json({ error: 'Employee ID is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('employee_id', sql.Int, employeeId) // Adjust sql type if needed
            .query('DELETE FROM Employee WHERE employee_id = @employee_id');

        if (result.rowsAffected[0] > 0) {
            res.json({ message: 'Employee deleted successfully' });
        } else {
            res.status(404).json({ message: 'Employee not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// Update Employee Info
// Update Employee Info
app.put('/api/employees/:employee_id', async (req, res) => {
    const employeeId = req.params.employee_id;
    const { first_name, last_name, job_title, date_hired, pay_rate, address, phone_number } = req.body;

    // Build dynamic query and parameters
    let query = 'UPDATE Employee SET ';
    let params = [];
    let paramIndex = 1;

    if (first_name) {
        query += `first_name = @first_name, `;
        params.push({ name: 'first_name', value: first_name, type: sql.VarChar });
    }
    if (last_name) {
        query += `last_name = @last_name, `;
        params.push({ name: 'last_name', value: last_name, type: sql.VarChar });
    }
    if (job_title) {
        query += `job_title = @job_title, `;
        params.push({ name: 'job_title', value: job_title, type: sql.VarChar });
    }
    if (date_hired) {
        query += `date_hired = @date_hired, `;
        params.push({ name: 'date_hired', value: date_hired, type: sql.Date });
    }
    if (pay_rate) {
        query += `pay_rate = @pay_rate, `;
        params.push({ name: 'pay_rate', value: pay_rate, type: sql.Decimal });
    }
    if (address) {
        query += `address = @address, `;
        params.push({ name: 'address', value: address, type: sql.VarChar });
    }
    if (phone_number) {
        query += `phone_number = @phone_number, `;
        params.push({ name: 'phone_number', value: phone_number, type: sql.VarChar });
    }

    // Remove trailing comma and add WHERE clause
    query = query.slice(0, -2) + ' WHERE employee_id = @employee_id';

    try {
        const pool = await sql.connect(dbConfig);
        const request = pool.request();
        
        // Add parameters to the request
        params.forEach(param => request.input(param.name, param.type, param.value));
        request.input('employee_id', sql.Int, employeeId);

        const result = await request.query(query);

        if (result.rowsAffected[0] > 0) {
            res.json({ employee_id: employeeId, ...req.body });
        } else {
            res.status(404).json({ message: 'Employee not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});



// Get Employee Info
app.get('/api/employees/:employee_id', async (req, res) => {
    const employeeId = req.params.employee_id;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('employee_id', sql.Int, employeeId)
            .query('SELECT * FROM Employee WHERE employee_id = @employee_id');

        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).json({ message: 'Employee not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// Get All Employees
app.get('/api/employees', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM Employee');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Add Clock In
app.post('/api/attendance/clockin', async (req, res) => {
    const { employee_id } = req.body;

    if (!employee_id) {
        return res.status(400).json({ error: 'Employee ID is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('employee_id', sql.Int, employee_id)
            .query(`
                INSERT INTO EmployeeAttendance (employee_id, clock_in_time, date) 
                VALUES (@employee_id, GETDATE(), CONVERT(date, GETDATE()))
            `);
        res.status(201).json({ message: 'Clock-in recorded successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// Add Clock Out
app.post('/api/attendance/clockout', async (req, res) => {
    const { employee_id } = req.body;

    if (!employee_id) {
        return res.status(400).json({ error: 'Employee ID is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('employee_id', sql.Int, employee_id)
            .query(`
                UPDATE EmployeeAttendance 
                SET clock_out_time = GETDATE() 
                WHERE employee_id = @employee_id 
                AND date = CONVERT(date, GETDATE()) 
                AND clock_out_time IS NULL
            `);

        if (result.rowsAffected[0] === 0) {
            res.status(404).json({ message: 'No clock-in record found for today or already clocked out' });
        } else {
            res.json({ message: 'Clock-out recorded successfully' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// Update Clock In
app.put('/api/employee-attendance/:attendance_id/clock-in', async (req, res) => {
    const { attendance_id } = req.params;
    const { clock_in_time } = req.body;

    // Validate input
    if (!clock_in_time) {
        return res.status(400).json({ error: 'Clock-in time is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('attendance_id', sql.Int, attendance_id)
            .input('clock_in_time', sql.DateTime, clock_in_time) // Adjust the type if needed
            .query(`
                UPDATE EmployeeAttendance 
                SET clock_in_time = @clock_in_time 
                WHERE attendance_id = @attendance_id
            `);

        if (result.rowsAffected[0] === 0) {
            res.status(404).json({ message: 'Record not found' });
        } else {
            res.json({ attendance_id, clock_in_time });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// Update Clock Out
app.put('/api/employee-attendance/:attendance_id/clock-out', async (req, res) => {
    const { attendance_id } = req.params;
    const { clock_out_time } = req.body;

    // Validate input
    if (!clock_out_time) {
        return res.status(400).json({ error: 'Clock-out time is required' });
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('attendance_id', sql.Int, attendance_id)
            .input('clock_out_time', sql.DateTime, clock_out_time) // Adjust type if necessary
            .query(`
                UPDATE EmployeeAttendance 
                SET clock_out_time = @clock_out_time 
                WHERE attendance_id = @attendance_id
            `);

        if (result.rowsAffected[0] === 0) {
            res.status(404).json({ message: 'Record not found' });
        } else {
            res.json({ attendance_id, clock_out_time });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get all attendance
app.get('/api/attendance', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM EmployeeAttendance');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

//get specific attendance
app.get('/api/attendance/:employee_id', async (req, res) => {
    const { employee_id } = req.params;
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('employee_id', sql.Int, employee_id)
            .query('SELECT * FROM EmployeeAttendance WHERE employee_id = @employee_id');

        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).json({ message: 'Attendance record not found' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


// Ingredients API Calls

// GET /ingredients: Retrieve all ingredients

app.get('/ingredients', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM Ingredient');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// GET /ingredients/:name: Retrieve a specific ingredient by name
app.get('/ingredients/:name', async (req, res) => {
    const { name } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .query('SELECT * FROM Ingredient WHERE ingredient_name = @name');

        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('Ingredient not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// POST /ingredients: Add a new ingredient
app.post('/ingredients', async (req, res) => {
    const { ingredient_name, quantity, vendor } = req.body; // `ingredient_id` should typically be auto-generated
    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('ingredient_name', sql.VarChar, ingredient_name)
            .input('quantity', sql.Int, quantity)
            .input('vendor', sql.VarChar, vendor)
            .query(`
                INSERT INTO Ingredient (ingredient_name, quantity, vendor) 
                VALUES (@ingredient_name, @quantity, @vendor)
            `);
        res.status(201).send('Ingredient added');
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// PUT /ingredients/:name/quantity: Update the quantity of an ingredient by name
app.put('/ingredients/:name/quantity', async (req, res) => {
    const { name } = req.params;
    const { quantity } = req.body;

    if (quantity === undefined || quantity === null) {
        return res.status(400).send('Quantity is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .input('quantity', sql.Int, quantity)
            .query(`
                UPDATE Ingredient 
                SET quantity = @quantity 
                WHERE ingredient_name = @name
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Quantity updated');
        } else {
            res.status(404).send('Ingredient not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// PUT /ingredients/:name/vendor: Update vendor information for an ingredient by name
app.put('/ingredients/:name/vendor', async (req, res) => {
    const { name } = req.params;
    const { vendor } = req.body;

    if (!vendor) {
        return res.status(400).send('Vendor information is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .input('vendor', sql.VarChar, vendor)
            .query(`
                UPDATE Ingredient
                SET vendor = @vendor 
                WHERE ingredient_name = @name
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Vendor information updated');
        } else {
            res.status(404).send('Ingredient not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});




// DELETE /ingredients/:name: Remove an ingredient by name
app.delete('/ingredients/:name', async (req, res) => {
    const { name } = req.params;

    if (!name) {
        return res.status(400).send('Ingredient name is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .query(`
                DELETE FROM Ingredient
                WHERE ingredient_name = @name
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Ingredient removed');
        } else {
            res.status(404).send('Ingredient not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// Recipe API Calls

// GET /recipes: Retrieve all recipes
app.get('/recipes', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM Recipe');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// GET /recipes/name/:name: Retrieve a specific recipe by name
app.get('/recipes/name/:name', async (req, res) => {
    const { name } = req.params;
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .query('SELECT * FROM Recipe WHERE recipe_name = @name');
        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('Recipe not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// POST /recipes: Create a new recipe
app.post('/recipes', async (req, res) => {
    const { recipe_id, item_id, recipe_name, steps } = req.body;
    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('recipe_id', sql.Int, recipe_id)
            .input('item_id', sql.Int, item_id)
            .input('recipe_name', sql.VarChar, recipe_name)
            .input('steps', sql.Text, steps)
            .query(`
                INSERT INTO Recipe (recipe_id, item_id, recipe_name, steps) 
                VALUES (@recipe_id, @item_id, @recipe_name, @steps)
            `);
        res.status(201).send('Recipe created');
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// PUT /recipes/name/:name: Update a recipe by name
app.put('/recipes/name/:name', async (req, res) => {
    const { name } = req.params;
    const { recipe_name, steps } = req.body;

    try {
        const pool = await sql.connect(dbConfig);
        
        // Update query for recipe_name; if you want to update the name, be cautious of changing it
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .input('recipe_name', sql.VarChar, recipe_name)
            .input('steps', sql.Text, steps)
            .query(`
                UPDATE Recipe 
                SET recipe_name = @recipe_name, 
                    steps = @steps 
                WHERE recipe_name = @name
            `);
            
        if (result.rowsAffected[0] > 0) {
            res.send('Recipe updated');
        } else {
            res.status(404).send('Recipe not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// DELETE /recipes/name/:name: Delete a recipe by name
app.delete('/recipes/name/:name', async (req, res) => {
    const { name } = req.params;

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('name', sql.VarChar, name)
            .query(`
                DELETE FROM Recipe 
                WHERE recipe_name = @name
            `);

        if (result.rowsAffected[0] > 0) {
            res.send('Recipe deleted');
        } else {
            res.status(404).send('Recipe not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// EmployeeAvailability API Calls

// GET /availability: Retrieve all employee availabilities
app.get('/availability', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM EmployeeAvailability');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// GET /availability/employee/:employee_id: Retrieve availability by employee ID
app.get('/availability/employee/:employee_id', async (req, res) => {
    const { employee_id } = req.params;
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('employee_id', sql.Int, employee_id)
            .query('SELECT * FROM EmployeeAvailability WHERE employee_id = @employee_id');
        if (result.recordset.length > 0) {
            res.json(result.recordset);
        } else {
            res.status(404).send('Availability not found for the specified employee');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


//add availability
// POST /api/availability: Add a new availability record
app.post('/api/availability', async (req, res) => {
    const { employee_id, can_work, cannot_work } = req.body;
    try {
        await sql.query(`
            INSERT INTO EmployeeAvailability (employee_id, can_work, cannot_work) 
            VALUES (@employee_id, @can_work, @cannot_work)`, 
        { 
            employee_id, 
            can_work, 
            cannot_work 
        });
        res.status(201).send('Availability added');
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// PUT /api/availability/employee/:employee_id: Update availability for a specific employee
app.put('/api/availability/employee/:employee_id', async (req, res) => {
    const { employee_id } = req.params;
    const { can_work, cannot_work } = req.body;

    // Ensure that at least one of the fields is provided
    if (can_work === undefined && cannot_work === undefined) {
        return res.status(400).send('At least one of "can_work" or "cannot_work" must be provided');
    }

    try {
        const pool = await sql.connect(dbConfig);

        // Construct the dynamic query based on provided fields
        let query = 'UPDATE EmployeeAvailability SET';
        const params = {};

        if (can_work !== undefined) {
            query += ' can_work = @can_work,';
            params.can_work = can_work;
        }
        if (cannot_work !== undefined) {
            query += ' cannot_work = @cannot_work,';
            params.cannot_work = cannot_work;
        }

        // Remove trailing comma and add WHERE clause
        query = query.slice(0, -1) + ' WHERE employee_id = @employee_id';
        params.employee_id = employee_id;

        // Execute the query
        const result = await pool.request()
            .input('can_work', sql.VarChar, params.can_work) // Adjust type if necessary
            .input('cannot_work', sql.VarChar, params.cannot_work) // Adjust type if necessary
            .input('employee_id', sql.Int, employee_id)
            .query(query);

        if (result.rowsAffected[0] > 0) {
            res.send('Availability updated');
        } else {
            res.status(404).send('Employee not found or no changes made');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



//Inventory Calls

// all items
app.get('/inventory', async (req, res) => {
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request().query('SELECT * FROM Inventory');
        res.json(result.recordset);
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// GET /inventory/name/:item_name: Retrieve a specific item by name
app.get('/inventory/name/:item_name', async (req, res) => {
    const { item_name } = req.params;
    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('item_name', sql.VarChar, item_name)
            .query('SELECT * FROM Inventory WHERE item_name = @item_name');
        if (result.recordset.length > 0) {
            res.json(result.recordset[0]);
        } else {
            res.status(404).send('Item not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


// add a new item
app.post('/inventory', async (req, res) => {
    const { item_id, item_name, quantity, price } = req.body;
    try {
        const pool = await sql.connect(dbConfig);
        await pool.request()
            .input('item_id', sql.Int, item_id)
            .input('item_name', sql.VarChar, item_name)
            .input('quantity', sql.Int, quantity)
            .input('price', sql.Decimal, price)
            .query('INSERT INTO Inventory (item_id, item_name, quantity, price) VALUES (@item_id, @item_name, @quantity, @price)');
        res.status(201).send('Item added');
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// PUT /inventory/name/:item_name/quantity: Update the quantity of an item by name
app.put('/inventory/name/:item_name/quantity', async (req, res) => {
    const { item_name } = req.params;
    const { quantity } = req.body;

    if (quantity === undefined) {
        return res.status(400).send('Quantity is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('item_name', sql.VarChar, item_name)
            .input('quantity', sql.Int, quantity)
            .query('UPDATE Inventory SET quantity = @quantity WHERE item_name = @item_name');

        if (result.rowsAffected[0] > 0) {
            res.send('Quantity updated');
        } else {
            res.status(404).send('Item not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});



// PUT /inventory/name/:item_name/price: Update the price of an item by name
app.put('/inventory/name/:item_name/price', async (req, res) => {
    const { item_name } = req.params;
    const { price } = req.body;

    if (price === undefined) {
        return res.status(400).send('Price is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('item_name', sql.VarChar, item_name)
            .input('price', sql.Decimal, price)
            .query('UPDATE Inventory SET price = @price WHERE item_name = @item_name');

        if (result.rowsAffected[0] > 0) {
            res.send('Price updated');
        } else {
            res.status(404).send('Item not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// DELETE /inventory/name/:item_name: Remove an item by name
app.delete('/inventory/name/:item_name', async (req, res) => {
    const { item_name } = req.params;

    if (!item_name) {
        return res.status(400).send('Item name is required');
    }

    try {
        const pool = await sql.connect(dbConfig);
        const result = await pool.request()
            .input('item_name', sql.VarChar, item_name)
            .query('DELETE FROM Inventory WHERE item_name = @item_name');

        if (result.rowsAffected[0] > 0) {
            res.send('Item deleted');
        } else {
            res.status(404).send('Item not found');
        }
    } catch (error) {
        res.status(500).send(error.message);
    }
});


app.listen(port, () => {
    console.log(`Server is running on port ${port}`); // Log server start message
});
