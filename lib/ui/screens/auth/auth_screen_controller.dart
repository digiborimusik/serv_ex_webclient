import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serv_expert_webclient/core/log.dart';
import 'package:serv_expert_webclient/data/exceptions.dart';
import 'package:serv_expert_webclient/data/models/client/client.dart';
import 'package:serv_expert_webclient/data/models/client/client_contact.dart';
import 'package:serv_expert_webclient/data/reposiotories/clients_repository.dart';
import 'package:serv_expert_webclient/data/reposiotories/companies_repository.dart';
import 'package:serv_expert_webclient/services/fireauth.dart';
import 'package:serv_expert_webclient/ui/screens/auth/auth_screen_state.dart';

class AuthScreenController extends StateNotifier<AuthScreenState> {
  AuthScreenController({
    required FireAuthService fireAuthService,
    required ClientsRepository clientsRepository,
    required CompaniesRepository companiesRepository,
  })  : _fireAuthService = fireAuthService,
        _clientsRepository = clientsRepository,
        _companiesRepository = companiesRepository,
        super(const ASSLoading());

  final FireAuthService _fireAuthService;
  final ClientsRepository _clientsRepository;
  final CompaniesRepository _companiesRepository;

  Future updateState() async {
    log('ASC updateState begin, current state: $state');

    bool authorized = _fireAuthService.authorized;

    log('Authorized: $authorized');

    if (!authorized) {
      state = const ASSUnauthorized();
    } else {
      state = const ASSLoading();
      try {
        await _clientsRepository.clientById(id: _fireAuthService.uid!, forceNetwork: true);
        state = const ASSAuthorized();
      } on UnexistedResource {
        state = ASSClientDetails(
          phone: _fireAuthService.phoneNumber,
          email: _fireAuthService.email,
          firstName: _fireAuthService.displayName?.split(' ').first,
          lastName: _fireAuthService.displayName?.split(' ').last,
        );
      } catch (e) {
        log(e);
        state = const ASSUpdateError();
      }
    }

    log('ASC updateState end, current state: $state');
  }

  signInWithPhone({required String phone}) async {
    AuthScreenState currentState = state;
    if (currentState is! ASSUnauthorized) throw Exception('Wrong state');
    if (currentState.busy) throw Exception('Controller is busy');

    log('signInWithPhone($phone)');

    state = const ASSUnauthorized(busy: true);
    try {
      await _fireAuthService.signInWithPhoneNumberWeb(phone);
      log('signInWithPhone($phone) sent sms');

      state = ASSsmsSent(phone: phone);
    } catch (e) {
      log(e);
      state = ASSUnauthorized(error: e.toString());
    }
  }

  confirmSmsCode({required String smsCode}) async {
    AuthScreenState currentState = state;
    if (currentState is! ASSsmsSent) throw Exception('Wrong state');
    if (currentState.busy) throw Exception('Controller is busy');

    log('confirmSmsCode($smsCode)');

    state = currentState.copyWith(busy: true, error: '');
    try {
      await _fireAuthService.confirmPhoneNumberWeb(smsCode);
      log('confirmSmsCode($smsCode) confirmed');

      updateState();
    } catch (e) {
      log(e);
      state = currentState.copyWith(busy: false, error: e.toString());
    }
  }

  submitClientDetails({required String firstName, required String lastName, required String email, required String phone}) async {
    AuthScreenState currentState = state;
    if (currentState is! ASSClientDetails) throw Exception('Wrong state');
    if (currentState.busy) throw Exception('Controller is busy');

    log('submitClientDetails($firstName, $lastName, $email, $phone)');

    state = currentState.copyWith(busy: true, error: '');

    try {
      Client newClient = Client(id: _fireAuthService.uid!, firstName: firstName, lastName: lastName, email: email, phone: phone);
      await _clientsRepository.setClient(newClient);
      log('submitClientDetails($firstName, $lastName, $email, $phone) submitted');

      state = const ASSClientContacts();
    } catch (e) {
      log(e);
      state = currentState.copyWith(busy: false, error: e.toString());
    }
  }

  submitClientContacts({required List<ClientContact> contacts}) async {
    AuthScreenState currentState = state;
    if (currentState is! ASSClientContacts) throw Exception('Wrong state');
    if (currentState.busy) throw Exception('Controller is busy');

    log('submitClientContacts($contacts)');

    state = currentState.copyWith(busy: true, error: '');

    try {
      await _clientsRepository.updateClientContacts(id: _fireAuthService.uid!, contacts: contacts);
      log('submitClientContacts($contacts) submitted');

      state = const ASSCompanyRegistration();
    } catch (e) {
      log(e);
      state = currentState.copyWith(busy: false, error: e.toString());
    }
  }

  submitCompanyRegistration({required String publicId, required String companyName, required String companyEmail}) async {
    AuthScreenState currentState = state;
    if (currentState is! ASSCompanyRegistration) throw Exception('Wrong state');
    if (currentState.busy) throw Exception('Controller is busy');

    log('submitCompanyRegistration($publicId, $companyName, $companyEmail)');

    state = currentState.copyWith(busy: true, error: '');

    try {
      await _companiesRepository.createCompany(publicId: publicId, companyName: companyName, companyEmail: companyEmail, memberId: _fireAuthService.uid!);
      log('submitCompanyRegistration($publicId, $companyName, $companyEmail) submitted');
      state = const ASSAuthorized();
    } catch (e) {
      log(e);
      state = currentState.copyWith(busy: false, error: e.toString());
    }
  }

  skipCompanyRegistration() async {
    AuthScreenState currentState = state;
    if (currentState is! ASSCompanyRegistration) throw Exception('Wrong state');
    if (currentState.busy) throw Exception('Controller is busy');

    log('skipCompanyRegistration()');
    state = const ASSAuthorized();
  }
}
