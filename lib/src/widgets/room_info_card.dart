import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../screens/home_screen.dart';
import '../utils/web_api_brain.dart';
import '../utils/app_state.dart';
import 'package:animate_do/animate_do.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:vibration/vibration.dart';
import 'package:vibration/vibration_presets.dart';

class RoomInfoCard extends StatefulWidget {

  @override
  State<RoomInfoCard> createState() => _RoomInfoCardState();
}

class _RoomInfoCardState extends State<RoomInfoCard> {

  WebApi webApi = WebApi();
  Vibration vibration = Vibration();

  dynamic lightsStatus, isWindowOpen,isFire;

  final buttonStyleEnabled = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    shadowColor: Colors.blue,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    minimumSize: const Size(double.infinity, 50),
  );

  Future<void> _vibrateDevice() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(preset: VibrationPreset.emergencyAlert);
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic isFire = Provider.of<AppState>(context, listen: false).update['isFire'];
    dynamic isWindowOpen = Provider.of<AppState>(context,listen: false).update['isWindowOpen'];
    dynamic lightsStatus = Provider.of<AppState>(context,listen: false).update['lightsStatus'];


    if ((Provider.of<AppState>(context,listen: true).update['isFire']).toString() == 'true' || (Provider.of<AppState>(context,listen: true).update['isWindowOpen']).toString() == 'true') {
      _vibrateDevice();
    }

    return GestureDetector(
      onTap: () async{
        print('Button Clicked');
        webApi.unlockDoor(context);
      },
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.45), BlendMode.darken),
                      child: Image.asset('images/room_image.jpg'),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 10,
                  child: Text(
                    "The Carnival",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // backgroundColor: Colors.black54,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    'Main Door',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      // backgroundColor: Colors.black54,
                    ),
                  ),
                ),
                Positioned(
                  top: 1,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 1.0),
                    color: Colors.black.withOpacity(0.7),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_open_rounded,
                          color:Colors.green,
                        ),
                        Text(
                          'Unlocked',
                          style: TextStyle(
                            color:Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Tada(
                    infinite: true,
                    animate: isFire.toString()=='true' ? true: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department_rounded,size: 27,color: (Provider.of<AppState>(context, listen: true).update['isFire']).toString() =="true"? Colors.red : Colors.grey,),
                        Text('Fire Sensor'),
                      ],
                    ),
                  ),
                  Tada(
                    infinite: true,
                    animate: isWindowOpen.toString()=='true'? true : false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.sensor_window,size: 27,color: ( Provider.of<AppState>(context,listen: true).update['isWindowOpen']).toString() =="true"? Colors.red : Colors.grey,),
                        Text('Window Sensor'),
                      ],
                    ),
                  ),
                  Tada(
                    infinite: true,
                    animate: lightsStatus.toString()=='true'? true : false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.ac_unit,size: 27,color: (Provider.of<AppState>(context,listen: true).update['lightsStatus']).toString()=='true'? Colors.cyan: Colors.grey,),
                        Text('AC Unit'),
                      ],
                    ),
                  ),

                  
                ],
              ),
            ),
            const SizedBox(height: 20,),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed:(){
                  webApi.unlockDoor(context);

                  ElegantNotification(
                      description:  Text("Please verifiy your data")
                  ).show(context);
                },
                style: buttonStyleEnabled,
                child:  Text(
                  "UNLOCK DOOR",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
