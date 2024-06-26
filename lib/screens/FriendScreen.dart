import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/getAPI.dart';
import 'package:gamegrid/screens/ProfileScreen.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen(this.userId, {super.key});

  final String userId;

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  void displayNotif(String message) {
    ElegantNotification.info(
      width: 360,
      toastDuration: const Duration(milliseconds: 2500),
      stackedOptions: StackedOptions(
        key: 'top',
        type: StackedType.same,
        itemOffset: const Offset(-5, -5),
      ),
      position: Alignment.topCenter,
      animation: AnimationType.fromTop,
      description: Text(message),
      shadow: BoxShadow(
        color: Colors.blue.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 5,
        offset: const Offset(0, 4), // changes position of shadow
      ),
    ).show(context);
  }

  var friends;
  void _getFriendList(String userId) async {
    var data = await ContentData.fetchFriendList(userId);

    setState(() {
      friends = data;
      built = true;
    });
  }

  String addFriendTextField = '';
  Future<void> _sendFriendRequest() async {
    if(addFriendTextField == GlobalData.displayName || addFriendTextField == '') return;
    var userData = await ContentData.searchUsers(addFriendTextField);

    if (userData.runtimeType == String) {
      displayNotif("User does not exist");
      return; //fetch error
    }

    String friendId = userData["id"];
    String retMessage =
        await ContentData.sendFriendRequest(friendId); //return message
    displayNotif(retMessage);
  }

  Future<void> _removeFriend(String friendId) async {
    var message = await ContentData.removeFriend(friendId);

    int i;
    for (i = 0; i < friends.length; i++) {
      if (friends[i]["id"] == friendId) break;
    }
    setState(() {
      friends.removeAt(i);
    });
  }

  String searchUserTextField = '';
  String confirmDeleteName = '';

  bool built = false;

  @override
  Widget build(BuildContext context) {
    if (!built) _getFriendList(widget.userId);
    Color background_color = const Color.fromRGBO(25, 28, 33, 1);
    Color text_color = const Color.fromRGBO(155, 168, 183, 1);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        actions: [
          (widget.userId == GlobalData.userID)
              ? Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    style: IconButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(10, 147, 150, 0.5),
                        padding: const EdgeInsets.all(3),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 30,
                    ), // Set icon color to white
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 10.0,
                            backgroundColor: const Color.fromRGBO(
                                54, 75, 94, 1), // Original background color
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(54, 75, 94,
                                    1), // Match the background color
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Search User',
                                    style: TextStyle(
                                      color: Colors.white, // White text color
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10.0),
                                  TextField(
                                    onChanged: (value) {
                                      searchUserTextField = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Enter display name',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400]),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors
                                                .white), // White underline color
                                      ),
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors
                                                .white), // Remove the border
                                      ),
                                    ),
                                    cursorColor:
                                        Colors.white, // White cursor color
                                    style: const TextStyle(
                                        color:
                                            Colors.white), // White text color
                                  ),
                                  const SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          searchUserTextField = '';
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .all<Color>(Colors
                                                  .grey), // Grey button color
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors
                                                  .white), // White text color
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if(searchUserTextField == GlobalData.displayName || searchUserTextField == '') {
                                            Navigator.pop(context);
                                            return;
                                          }
                                          var data = await ContentData.searchUsers(searchUserTextField);
                                          if(data.runtimeType == String) {
                                            displayNotif("User does not exist");
                                          }
                                          else {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProfileScreen(data["displayName"]))
                                            );
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .all<Color>(const Color.fromRGBO(
                                                  10,
                                                  147,
                                                  150,
                                                  1)), // Specified button color
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Search',
                                          style: TextStyle(
                                              color: Colors
                                                  .white), // White text color
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              : const SizedBox(),
          (widget.userId == GlobalData.userID)
              ? Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    style: IconButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(10, 147, 150, 0.5),
                        padding: const EdgeInsets.all(3),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 30,
                    ), // Set icon color to white
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 10.0,
                            backgroundColor: const Color.fromRGBO(
                                54, 75, 94, 1), // Original background color
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(54, 75, 94,
                                    1), // Match the background color
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Send Friend Request',
                                    style: TextStyle(
                                      color: Colors.white, // White text color
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10.0),
                                  TextField(
                                    onChanged: (value) {
                                      addFriendTextField = value;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Enter display name',
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400]),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors
                                                .white), // White underline color
                                      ),
                                      border: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors
                                                .white), // Remove the border
                                      ),
                                    ),
                                    cursorColor:
                                        Colors.white, // White cursor color
                                    style: const TextStyle(
                                        color:
                                            Colors.white), // White text color
                                  ),
                                  const SizedBox(height: 20.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          addFriendTextField = '';
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .all<Color>(Colors
                                                  .grey), // Grey button color
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Colors
                                                  .white), // White text color
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _sendFriendRequest();
                                          Navigator.of(context).pop();
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty
                                              .all<Color>(const Color.fromRGBO(
                                                  10,
                                                  147,
                                                  150,
                                                  1)), // Specified button color
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Send',
                                          style: TextStyle(
                                              color: Colors
                                                  .white), // White text color
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              : const SizedBox()
        ],
      ),
      body: (friends != null)
          ? Container(
              color: background_color,
              child: (friends.length != 0)
                  ? ListView.builder(
                      itemCount:
                          friends.length, // Placeholder for number of reviews
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ListTile(
                                leading: Icon(
                                  Icons.person,
                                  color: text_color,
                                ),
                                title: Text(
                                  friends[index]["displayName"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                trailing: (confirmDeleteName ==
                                        friends[index]["displayName"])
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          OutlinedButton(
                                              onPressed: () {
                                                _removeFriend(
                                                    friends[index]["id"]);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 5),
                                                  minimumSize: Size.zero,
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: text_color))),
                                              child: Text(
                                                'CONFIRM',
                                                style: TextStyle(
                                                    color: text_color,
                                                    fontSize: 12),
                                              )),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          OutlinedButton(
                                              onPressed: () {
                                                setState(() {
                                                  confirmDeleteName = '';
                                                });
                                              },
                                              style: OutlinedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 5),
                                                  minimumSize: Size.zero,
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                  shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: text_color))),
                                              child: Text(
                                                'NO',
                                                style: TextStyle(
                                                    color: text_color,
                                                    fontSize: 12),
                                              ))
                                        ],
                                      )
                                    : (widget.userId == GlobalData.userID)
                                        ? IconButton(
                                            style: IconButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              splashFactory:
                                                  NoSplash.splashFactory,
                                            ),
                                            icon: const Icon(
                                              Icons.delete,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                confirmDeleteName =
                                                    friends[index]
                                                        ["displayName"];
                                              });
                                            })
                                        : const SizedBox(),
                                onTap: () {
                                  (friends[index]["id"] != GlobalData.userID)
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(friends[index]
                                                      ["displayName"])))
                                      : ();
                                }),
                            const Divider(
                              color: Colors.black26,
                              height: 0,
                            ),
                          ],
                        );
                      })
                  : Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 25),
                      child: Text(
                        "No Friends yet :(",
                        style: TextStyle(
                          color: text_color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
          : Container(
              color: background_color,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                strokeWidth: 6,
                color: Color.fromRGBO(10, 147, 150, 0.5),
              )),
    );
  }
}
