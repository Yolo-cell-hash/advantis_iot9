import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/services.dart';
import '../utils/app_state.dart';

class MenuWidget extends StatefulWidget {
  const MenuWidget({super.key});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: double.infinity,
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.all(15),
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Carnival',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Advantis IoT 9',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Divider(
                        height: 2,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text('The Carnival',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          )),
                      Text(
                        "Room : 007",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Check In : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Check Out :  ${DateTime.now().day+5}/${DateTime.now().month}/${DateTime.now().year}",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Card(
                child: GestureDetector(
                  onTap: (){

                    Provider.of<AppState>(context, listen: false).otpSent = false;

                    Navigator.pushNamed(context, '/home');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        Text('  Logout'),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
