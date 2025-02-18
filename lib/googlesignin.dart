import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [drive.DriveApi.driveFileScope],
);

Future<Map<String, String>?> loginToDrive() async {
  final GoogleSignInAccount? account = await googleSignIn.signIn();
  if (account == null) {
    return null; // User canceled the sign-in
  }
  return await account.authHeaders; // Return the auth headers
}