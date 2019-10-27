import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../module_common.dart';
import 'package:permission/permission.dart';

class InstructionPage extends StatefulWidget {
  @override
  InstructionPageState createState() {
    return new InstructionPageState();
  }
}

class InstructionPageState extends State<InstructionPage> {

  @override
  void initState() {
    super.initState();
    gerPerm();
  }

  gerPerm() async {
    var permissions = await Permission.getPermissionsStatus(
        [PermissionName.Location, PermissionName.Location]);

    var permissionNames = await Permission.requestPermissions(
        [PermissionName.Location, PermissionName.Camera]);

    Permission.openSettings;
  }

  @override
  Widget build(BuildContext context) {
    return CreateDefaultMasterForm(0, getBody(), context, null);
  }

  GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  getBody() {
    return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ));
  }


}
