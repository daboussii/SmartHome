const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.deleteUser = functions.https.onCall(async (data, context) => {
  // Vérifiez que l'utilisateur est authentifié et a les permissions nécessaires
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only administrators can delete users.'
    );
  }

  const email = data.email;

  try {
    // Rechercher l'utilisateur par email dans Firebase Auth
    const userRecord = await admin.auth().getUserByEmail(email);

    // Supprimer l'utilisateur dans Firebase Auth
    await admin.auth().deleteUser(userRecord.uid);

    return { message: 'User deleted successfully' };
  } catch (error) {
    console.error('Error deleting user:', error);
    throw new functions.https.HttpsError('not-found', 'User not found');
  }
});
