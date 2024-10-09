class Task {
  int taskId; // Non-nullable
  String description; // Non-nullable
  DateTime createDate; // Non-nullable
  DateTime dueDate; // Non-nullable
  String assignedBy; // Non-nullable

  Task({
    required this.taskId,
    required this.description,
    required this.createDate,
    required this.dueDate,
    required this.assignedBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['TaskID'] ?? 0, // Default to 0 if TaskID is null
      description: json['Description'] ?? '', // Default to empty string if Description is null
      createDate: json['CreateDate'] != null ? DateTime.parse(json['CreateDate']) : DateTime.now(), // Default to now if CreateDate is null
      dueDate: json['DueDate'] != null ? DateTime.parse(json['DueDate']) : DateTime.now(), // Default to now if DueDate is null
      assignedBy: json['AssignedBy'] ?? '', // Default to empty string if AssignedBy is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TaskID': taskId, // taskId is non-nullable
      'Description': description, // description is non-nullable
      'CreateDate': createDate.toIso8601String(), // createDate is non-nullable
      'DueDate': dueDate.toIso8601String(), // dueDate is non-nullable
      'AssignedBy': assignedBy, // assignedBy is non-nullable
    };
  }
}
