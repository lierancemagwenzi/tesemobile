import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/client/categories/categories.dart';
import 'package:smacredit/client/channels/category_channels.dart';
import 'package:smacredit/client/channels/channel.dart';
import 'package:smacredit/client/channels/playlist.dart';
import 'package:smacredit/client/downloads/widgets/downloads.dart';
import 'package:smacredit/client/models/dashboard_model.dart' as ds;

import 'package:smacredit/client/categories/category.dart';
import 'package:smacredit/client/creators/creator_profile.dart';
import 'package:smacredit/client/creators/creators.dart';
import 'package:smacredit/client/events/all_live_events.dart';
import 'package:smacredit/client/events/past_events.dart';
import 'package:smacredit/client/events/upcoming_events.dart';
import 'package:smacredit/client/home/dashboad.dart';
import 'package:smacredit/client/models/dashboard_model.dart';
import 'package:smacredit/client/payments/visa_matercard_payment.dart';
import 'package:smacredit/client/payments/widgets/ecocash_payment.dart';
import 'package:smacredit/client/players/video_player_widget.dart';
import 'package:smacredit/client/profile/account_settings.dart';
import 'package:smacredit/client/profile/personal_details.dart';
import 'package:smacredit/src/addresses/AddAddressWidget.dart';
import 'package:smacredit/src/addresses/AddNextOfKinWidget.dart';
import 'package:smacredit/src/addresses/AddressesWidget.dart';
import 'package:smacredit/src/addresses/NextOfKinModel.dart';
import 'package:smacredit/src/addresses/SignatureWidget.dart';
import 'package:smacredit/src/addresses/models/DocumentTypeModel.dart';
import 'package:smacredit/src/auth/widgets/landing_screen.dart';
import 'package:smacredit/src/auth/widgets/models/CheckEmailWidget.dart';
import 'package:smacredit/src/auth/widgets/models/FirstWidget.dart';
import 'package:smacredit/src/auth/widgets/models/ForgotPasswordWidget.dart';
import 'package:smacredit/src/auth/widgets/models/IDDocumentPickerWidget.dart';
import 'package:smacredit/src/auth/widgets/models/OTPWidget.dart';
import 'package:smacredit/src/auth/widgets/models/PassportPickerWidget.dart';
import 'package:smacredit/src/auth/widgets/models/RegistrationImagesWidget.dart';
import 'package:smacredit/src/auth/widgets/models/RegistrationSelectCountry.dart';
import 'package:smacredit/src/auth/widgets/models/ResetPassword.dart';
import 'package:smacredit/src/auth/widgets/models/VerifyDetailsWidget.dart';
import 'package:smacredit/src/auth/widgets/models/client_login.dart';
import 'package:smacredit/src/auth/widgets/models/client_registration.dart';
import 'package:smacredit/src/auth/widgets/models/onboarding_widget.dart';
import 'package:smacredit/src/auth/widgets/models/policy_widget.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/widgets/channel_page.dart';
import 'package:smacredit/src/content-creator/widgets/channels_widget.dart';
import 'package:smacredit/src/content-creator/widgets/create_channel.dart';
import 'package:smacredit/src/content-creator/widgets/create_playlist.dart';
import 'package:smacredit/src/content-creator/widgets/create_video.dart';
import 'package:smacredit/src/content-creator/widgets/playlist_screen.dart';
import 'package:smacredit/src/content-creator/widgets/trailer_player.dart';
import 'package:smacredit/src/content-creator/widgets/update_channe.dart';
import 'package:smacredit/src/content-creator/widgets/update_playlist.dart';
import 'package:smacredit/src/content-creator/widgets/update_video.dart';
import 'package:smacredit/src/content-creator/widgets/video_description.dart';
import 'package:smacredit/src/content-creator/widgets/video_player.dart';
import 'package:smacredit/src/credit/PaymentWidget.dart';
import 'package:smacredit/src/credit/models/CreditApplication.dart';
import 'package:smacredit/src/credit/models/PaymentResponse.dart';
import 'package:smacredit/src/employment/AddEmploymentWidget.dart';
import 'package:smacredit/src/employment/EmployerDetailsWidget.dart';
import 'package:smacredit/src/employment/EmploymentHistoryWidget.dart';
import 'package:smacredit/src/employment/PendingVerificationWidget.dart';
import 'package:smacredit/src/employment/SelectCompanyWidget.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/employment/models/EmployerModel.dart';
import 'package:smacredit/src/expenses/CustomerExpensesWidget.dart';
import 'package:smacredit/src/home/HomeWidget.dart';
import 'package:smacredit/src/home/models/user_stats.dart';
import 'package:smacredit/src/payments/models/bank_account.dart';
import 'package:smacredit/src/payments/models/payout_model.dart';
import 'package:smacredit/src/payments/models/transaction_model.dart';
import 'package:smacredit/src/payments/widgets/client_payment_link_details.dart';
import 'package:smacredit/src/payments/widgets/create_paylink_link.dart';
import 'package:smacredit/src/payments/widgets/creator_payment_links.dart';
import 'package:smacredit/src/payments/widgets/payment_link_details.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/notifications/widgets/notifications.dart';
import 'package:smacredit/src/payments/widgets/payout_detail.dart';
import 'package:smacredit/src/payments/widgets/payout_request.dart';
import 'package:smacredit/src/payments/widgets/transaction_detail.dart';
import 'package:smacredit/src/profile/models/account_info.dart';
import 'package:smacredit/src/profile/widgets/client_profile.dart';
import 'package:smacredit/src/profile/widgets/update_bank.dart';
import 'package:smacredit/src/profile/widgets/update_banking_info.dart';
import 'package:smacredit/src/profile/widgets/update_payment_profile.dart';
import 'package:smacredit/src/profile/widgets/update_profile_info.dart';
import 'package:smacredit/src/profile/widgets/upload_document.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/scanner/IDScanner.dart';
import 'package:smacredit/src/splash/splashscreen.dart';
import 'package:smacredit/src/widgets/LostWidget.dart';

import 'auth/models/RegistrationDocumentsModel.dart';
import 'credit/ProductDetailsWidget.dart';
import 'package:smacredit/src/models/UserModel.dart' as user;

import 'credit/ScanToPay.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/Splash':
        return CupertinoPageRoute(builder: (_) => SplashScreen());

      //client

      case '/ClientDashboard':
        return CupertinoPageRoute(
          builder: (_) => isV1
              ? HomeWidget(index: args != null ? args as int : null)
              : ClientDashboardWidget(),
        );

      //events

      case '/LiveEvents':
        return CupertinoPageRoute(builder: (_) => ViewLiveEventsWidget());

      case '/UpcomingEvents':
        return CupertinoPageRoute(
          builder: (_) => ViewAllUpcomingEventsWidget(),
        );

      case '/PastEvents':
        return CupertinoPageRoute(builder: (_) => PastEventsWidget());

      case '/Downloads':
        return CupertinoPageRoute(builder: (_) => DownloadsScreen());

      //players
      case '/Player':
        final args = settings.arguments as Map;
        return CupertinoPageRoute(
          builder: (_) => TeseVideoPlayerWidget(
            // channel: args['channel'] as Channel,
            video: args['video'] as Video,
          ),
        );

      case '/OnBoarding':
        return CupertinoPageRoute(builder: (_) => OnBoardingWidget());
      case '/SelectCountry':
        return CupertinoPageRoute(
          builder: (_) => RegistrationSelectCountryWidget(),
        );

      case '/CheckEmail':
        return CupertinoPageRoute(builder: (_) => CheckEmailWidget());
      case '/Category':
        return CupertinoPageRoute(
          builder: (_) => CategoryWidget(category: args as ds.Category),
        );
      case '/CategoryExplorer':
        return CupertinoPageRoute(builder: (_) => TeseCategoryExplorer());

      case '/CreatorExplorer':
        return CupertinoPageRoute(builder: (_) => CreatorGallery());

      case '/PlaylistVideos':
        final args = settings.arguments as Map;

        return CupertinoPageRoute(
          builder: (_) => PlayListVideosWidget(
            playlist: args['playlist'] as Playlist,
            // channel: args['channel'] as Channel,
          ),
        );

      case '/CreatorProfile':
        return CupertinoPageRoute(
          builder: (_) => CreatorProfileScreen(user: args as user.User),
        );

      case '/PersonalDetails':
        return CupertinoPageRoute(builder: (_) => PersonalDetailsScreen());

      case '/AccountSettings':
        return CupertinoPageRoute(builder: (_) => AccountSettingsScreen());

      case '/CreatorChannelView':
        return CupertinoPageRoute(
          builder: (_) =>
              ClientChannelPlaylistsWidget(channel: args as Channel),
        );

      case '/VideoPlayer':
        return CupertinoPageRoute(
          builder: (_) => AntMediaVideoPlayer(video: args as Video),
        );
      case '/VideoDetails':
        final args = settings.arguments as Map;
        return CupertinoPageRoute(
          builder: (_) => FullVideoDetailView(
            video: args['video'] as Video,
            channel: args['channel'] as Channel,
            playlist: args['playlist'] as Playlist,
          ),
        );

      case '/VideoTrailer':
        final args = settings.arguments as Map;
        return CupertinoPageRoute(
          builder: (_) => TrailerPlayerWidget(
            video: args['video'] as Video,
            channel: args['channel'] as Channel,
            playlist: args['playlist'] as Playlist,
          ),
        );

      case '/UpdateProfile':
        return CupertinoPageRoute(builder: (_) => UpdateProfileScreen());

      case '/ClientProfile':
        return CupertinoPageRoute(
          builder: (_) => ClientProfileWidget(onPop: () {}),
        );

      case '/Notifications':
        return CupertinoPageRoute(builder: (_) => NotificationsScreen());
      case '/UploadDocument':
        return CupertinoPageRoute(builder: (_) => UploadDocumentWidget());

      case '/UpdateBankingDetails':
        return CupertinoPageRoute(
          builder: (_) =>
              UpdateBankingInfoWidget(accountInfo: args as AccountInfo),
        );

      case '/TransactionDetails':
        return CupertinoPageRoute(
          builder: (_) =>
              TransactionDetailScreen(transaction: args as TransactionModel),
        );
      case '/RequestPayout':
        return CupertinoPageRoute(
          builder: (_) => PayoutRequestWidget(priceModel: args as PriceModel),
        );

      case '/UpdatePaymentProfile':
        return CupertinoPageRoute(
          builder: (_) =>
              UpdatePaymentProfileScreen(accountInfo: args as AccountInfo),
        );
      case '/UpdateBank':
        return CupertinoPageRoute(
          builder: (_) => UpdateBankWidget(accountInfo: args as BankAccount),
        );
      // case '/Dashboard':
      //   return CupertinoPageRoute(
      //     builder: (_) =>
      //         currentuser.value.token == null ||
      //             currentuser.value.user?.isClient == true
      //         ? ClientDashboardWidget()
      //         : HomeWidget(index: args != null ? args as int : null),
      // );
      // case '/Dashboard':
      //   return CupertinoPageRoute(
      //     builder: (_) => HomeWidget(index: args != null ? args as int : null),
      //   );

      case '/Dashboard':
        return CupertinoPageRoute(
          builder: (_) => isV1
              ? HomeWidget(index: args != null ? args as int : null)
              : ClientDashboardWidget(),
        );
      case '/CreatePaymentLink':
        return CupertinoPageRoute(builder: (_) => CreatePaymentLinkScreen());

      case '/CreatorPaymentLinks':
        return CupertinoPageRoute(
          builder: (_) => CreatorPaymentLinksWidget(creator: args as user.User),
        );

      case '/Cat':
        return CupertinoPageRoute(
          builder: (_) => ChannelsDirectoryScreen(category: args as Category),
        );

      case '/PaymentLinkDetails':
        Map<String, dynamic> data = args as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (_) => PaymentLinkSuccessScreen(
            isNew: data['isNew'],
            paymentLink: data['link'],
          ),
        );

      case '/ClientPaymentLinkDetails':
        Map<String, dynamic> data = args as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (_) => ClientPaymentLinkDetailsWidget(
            isNew: data['isNew'],
            paymentLink: data['link'],
          ),
        );

      case '/Expenses':
        return CupertinoPageRoute(builder: (_) => CustomerExpensesWidget());

      case '/ProductDetails':
        return CupertinoPageRoute(
          builder: (_) =>
              ProductDetailsWidget(application: args as CreditApplication),
        );
      case '/PayoutDetail':
        return CupertinoPageRoute(
          builder: (_) => PayoutDetailScreen(transaction: args as PayoutModel),
        );
      case '/MakePayment':
        return CupertinoPageRoute(
          builder: (_) => Paymentwidget(response: args as PaymentResponse),
        );

      case '/VisaMastercardPayment':
        return CupertinoPageRoute(
          builder: (_) => VisMasterCardPayment(paymentCode: args as String),
        );

      case '/PaymentWaitingScreen':
        return CupertinoPageRoute(
          builder: (_) => PaymentWaitingScreen(phoneNumber: args as String),
        );

      case '/ScanToPay':
        return CupertinoPageRoute(builder: (_) => const ScanToPay());
      case '/Employment':
        return CupertinoPageRoute(builder: (_) => EmploymentHistoryWidget());
      case '/IDScanner':
        return CupertinoPageRoute(builder: (_) => IDScannerWidget());
      case '/AddNextKin':
        return CupertinoPageRoute(
          builder: (_) => AddNextOfKinWidget(
            nextOfKinModel: args != null ? args as NextOfKinModel : null,
          ),
        );
      case '/Signature':
        return CupertinoPageRoute(
          builder: (_) =>
              SignatureWidget(documentTypeModel: args as DocumentTypeModel),
        );
      case '/Profile':
        return CupertinoPageRoute(builder: (_) => AddressesWidget());
      case '/Personal':
        return CupertinoPageRoute(builder: (_) => AddAddressWidget());
      case '/ForgotPassword':
        return CupertinoPageRoute(builder: (_) => ForgotPasswordWidget());
      case '/SelectCompany':
        return CupertinoPageRoute(builder: (_) => const SelectCompanyWidget());
      case '/PendingVerification':
        return CupertinoPageRoute(
          builder: (_) => const PendingVerificationWidget(),
        );
      case '/AddEmployer':
        return CupertinoPageRoute(
          builder: (_) =>
              AddEmploymentWidget(employerModel: args as EmployerModel),
        );
      case '/Employer':
        return CupertinoPageRoute(
          builder: (_) => EmployerDetailsWidget(
            customerEmployerModel: args as CustomerEmployerModel,
          ),
        );
      case '/VerifyDetails':
        return CupertinoPageRoute(
          builder: (_) => VerifyDetailsWidget(
            registrationDocumentsModel: args as RegistrationDocumentsModel,
          ),
        );
      case '/OTP':
        Map<String, dynamic> payload = args as Map<String, dynamic>;
        return CupertinoPageRoute(
          builder: (_) => OTPWidget(
            userModel: payload['user'] as UserModel,
            action: payload['action'] as String,
          ),
        );

      case '/ResetPassword':
        return CupertinoPageRoute(
          builder: (_) => ResetPasswordWidget(userModel: args as UserModel),
        );
      case '/RegistrationImages':
        return CupertinoPageRoute(
          builder: (_) => RegistrationImagesWidget(country: args as Country),
        );

      case '/ClientRegistration':
        return CupertinoPageRoute(
          builder: (_) => ClientRegistrationWidget(country: args as Country),
        );

      case '/IDPicker':
        return CupertinoPageRoute(builder: (_) => IDPickerWidget());

      case '/PassportPicker':
        return CupertinoPageRoute(builder: (_) => PassportPickerWidget());
      // case '/RegisterDetails':
      //   return CupertinoPageRoute(builder: (_) => RegisterDetailsWidget());
      case '/Login':
        return CupertinoPageRoute(
          builder: (_) =>
              TeseLoginScreen(message: args != null ? args as String : null),
        );

      case '/ClientLogin':
        return CupertinoPageRoute(
          builder: (_) =>
              TeseLoginScreen(message: args != null ? args as String : null),
        );

      case "/First":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return isV1 ? FirstWidget() : TeseLandingScreen();
          },
        );
      case "/CreateChannel":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return CreateChannelPage();
          },
        );

      case "/EditChannel":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return UpdateChannelPage(channel: args as Channel);
          },
        );

      case "/Channel":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return ChannelPreview(channel: args as Channel);
          },
        );

      case "/CreatePlaylist":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return FacebookCreatePlaylist(channel: args as Channel);
          },
        );

      case "/UpdatePlaylist":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return UpdatePlayListWidget(playlist: args as Playlist);
          },
        );

      case "/Playlist":
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return UnifiedPlaylistScreen(
              playlist: args['playlist'] as Playlist,
              channel: args['channel'] as Channel,
            );
          },
        );

      case "/AddVideoScreen":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return AddVideoScreen(playlist: args as Playlist);
          },
        );

      case "/Policy":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return TesePrivacyPolicyScreen();
          },
        );

      case "/UpdateVideoScreen":
        final args = settings.arguments as Map;
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return UpdateVideoScreen(
              video: args['video'] as Video,
              channel: args['channel'] as Channel,
              playlist: args['playlist'] as Playlist,
            );
          },
        );
      case "/ChannelListScreen":
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return ChannelListScreen(onPop: () {});
          },
        );

      default:
        // If there is no such named route in the switch statement, e.g. /third
        return CupertinoPageRoute(builder: (_) => LostWidget());
    }
  }
}
