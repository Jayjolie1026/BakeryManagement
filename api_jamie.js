// Add Employee
app.post('/api/employees', (req, res) => {
    const { first_name, last_name, job_title, date_hired, pay_rate, address, phone_number } = req.body;
    const query = 'INSERT INTO Employee (first_name, last_name, job_title, date_hired, pay_rate, address, phone_number) VALUES (?, ?, ?, ?, ?, ?, ?)';
    db.query(query, [first_name, last_name, job_title, date_hired, pay_rate, address, phone_number], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ employee_id: results.insertId, ...req.body });
    });
});

// Remove Employee
app.delete('/api/employees/:employee_id', (req, res) => {
    const { employee_id } = req.params;
    const query = 'DELETE FROM Employee WHERE employee_id = ?';
    db.query(query, [employee_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.affectedRows === 0) return res.status(404).json({ message: 'Employee not found' });
        res.json({ message: 'Employee deleted successfully' });
    });
});

// Update Employee Info
app.put('/api/employees/:employee_id', (req, res) => {
    const { employee_id } = req.params;
    const { first_name, last_name, job_title, date_hired, pay_rate, address, phone_number } = req.body;
    const query = 'UPDATE Employee SET first_name = ?, last_name = ?, job_title = ?, date_hired = ?, pay_rate = ?, address = ?, phone_number = ? WHERE employee_id = ?';
    db.query(query, [first_name, last_name, job_title, date_hired, pay_rate, address, phone_number, employee_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.affectedRows === 0) return res.status(404).json({ message: 'Employee not found' });
        res.json({ employee_id, ...req.body });
    });
});

// Get Employee Info
app.get('/api/employees/:employee_id', (req, res) => {
    const { employee_id } = req.params;
    const query = 'SELECT * FROM Employee WHERE employee_id = ?';
    db.query(query, [employee_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.length === 0) return res.status(404).json({ message: 'Employee not found' });
        res.json(results[0]);
    });
});

// Get All Employees
app.get('/api/employees', (req, res) => {
    const query = 'SELECT * FROM Employee';
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Add Clock In
app.post('/api/attendance/clockin', (req, res) => {
    const { employee_id } = req.body;
    const query = 'INSERT INTO EmployeeAttendance (employee_id, clock_in_time, date) VALUES (?, NOW(), CURDATE())';
    db.query(query, [employee_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(201).json({ message: 'Clock-in recorded successfully' });
    });
});

// Add Clock Out
app.post('/api/attendance/clockout', (req, res) => {
    const { employee_id } = req.body;
    const query = 'UPDATE EmployeeAttendance SET clock_out_time = NOW() WHERE employee_id = ? AND date = CURDATE() AND clock_out_time IS NULL';
    db.query(query, [employee_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.affectedRows === 0) return res.status(404).json({ message: 'No clock-in record found for today' });
        res.json({ message: 'Clock-out recorded successfully' });
    });
});

// Update Clock In
app.put('/api/employee-attendance/:attendance_id/clock-in', (req, res) => {
    const { attendance_id } = req.params;
    const { clock_in_time } = req.body;

    const query = 'UPDATE EmployeeAttendance SET clock_in_time = ? WHERE attendance_id = ?';
    db.query(query, [clock_in_time, attendance_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.affectedRows === 0) return res.status(404).json({ message: 'Record not found' });
        res.json({ attendance_id, clock_in_time });
    });
});

// Update Clock Out
app.put('/api/employee-attendance/:attendance_id/clock-out', (req, res) => {
    const { attendance_id } = req.params;
    const { clock_out_time } = req.body;

    const query = 'UPDATE EmployeeAttendance SET clock_out_time = ? WHERE attendance_id = ?';
    db.query(query, [clock_out_time, attendance_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.affectedRows === 0) return res.status(404).json({ message: 'Record not found' });
        res.json({ attendance_id, clock_out_time });
    });
});

// Remove Clock In/Out
app.delete('/api/employee-attendance/:attendance_id/clock-in', (req, res) => {
    const { attendance_id } = req.params;

    const query = 'DELETE FROM EmployeeAttendance WHERE attendance_id = ?';
    db.query(query, [attendance_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.affectedRows === 0) return res.status(404).json({ message: 'Record not found' });
        res.json({ message: 'Clock-in record removed successfully' });
    });
});


// Get Attendance Records for Specific Employee
app.get('/api/attendance/:employee_id', (req, res) => {
    const { employee_id } = req.params;
    const query = 'SELECT * FROM EmployeeAttendance WHERE employee_id = ?';
    db.query(query, [employee_id], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// Get All Attendance Records
app.get('/api/attendance', (req, res) => {
    const query = 'SELECT * FROM EmployeeAttendance';
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});
