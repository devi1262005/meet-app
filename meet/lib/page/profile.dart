import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Initial values for the profile information
  String username = '';
  String phoneNumber = '';
  String location = '';
  String bio = '';
  String status = 'Available';

  // Function to open the edit dialog
  void _editField(String field, String currentValue, ValueChanged<String> onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.3),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.black.withOpacity(0.2),
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture and Name Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/profile_pic.jpg'), // Replace with actual profile picture
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        // Add your code to edit profile picture here
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'John Doe', // Replace with dynamic user data
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 5),
            Center(child: Text('john.doe@example.com', style: TextStyle(color: Colors.grey))),
            SizedBox(height: 20),

            // Personal Details Section
            Text('Personal Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            ListTile(
              title: Text('Username'),
              subtitle: Text(username),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editField('Username', username, (newValue) {
                    setState(() {
                      username = newValue;
                    });
                  });
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Phone Number'),
              subtitle: Text(phoneNumber),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editField('Phone Number', phoneNumber, (newValue) {
                    setState(() {
                      phoneNumber = newValue;
                    });
                  });
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Location'),
              subtitle: Text(location),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editField('Location', location, (newValue) {
                    setState(() {
                      location = newValue;
                    });
                  });
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Bio'),
              subtitle: Text(bio),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _editField('Bio', bio, (newValue) {
                    setState(() {
                      bio = newValue;
                    });
                  });
                },
              ),
            ),
            Divider(),

            SizedBox(height: 20),

            // Availability Status Section
            ListTile(
              title: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: DropdownButton<String>(
                value: status,
                items: <String>['Available', 'Busy', 'Do Not Disturb'].map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newStatus) {
                  setState(() {
                    status = newStatus ?? 'Available';
                  });
                },
              ),
            ),
          
            SizedBox(height: 20),
            
            // Action Button to Log Out
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Log Out action
                },
                icon: Icon(Icons.logout),
                label: Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
