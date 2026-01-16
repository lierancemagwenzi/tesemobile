class Validator{

 static String? validatePhone(String? value){
    if(value!.isEmpty){

      return "Phone is required";
    }
    else{

      final phoneNumberRegExp = RegExp(r'^(?:\+27|27|0)(6|7|8){1}([0-9]{1})([0-9]{7})$');
      if (!phoneNumberRegExp.hasMatch(value!)) {
        return "Enter a valid phone number";
      }
      else{
        return null;
      }
    }

  }
 static String? validateEmail(String? value){
   if(value!.isEmpty){
     return "Email is required";
   }
   else{
     if (!value.isValidEmail()) {
       return "Enter a valid email";
     }
     else{
       return null;
     }
   }

 }

 static String? validatePassword(String? value){
   if(value!.isEmpty){
     return "Password is required";
   }
   else{
     final phoneNumberRegExp = RegExp( r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
     if (value.length<6) {
       return "Password should be of length at least 6";
     }
     else{
       return null;
     }
   }

 }

 static String? validateConfirmPassword(String? password, String? value){

   if(password!.isEmpty|| validatePassword(password)!=null ){

     return null;
   }

   else{

     if(value!=password){
       return 'passwords do not match';
     }

     else{

       return null;
     }
   }



 }

 static String? validateRequired(String? value){

   if(value!.isNotEmpty){

     return null;
   }

   else{

       return 'Value is required';

   }



 }

 static String? validateNum (String? value){

   if(value!.isNotEmpty&& num.tryParse(value)!=null){

     return null;
   }

   else{

     return 'A valid number is required';

   }



 }

}
extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
