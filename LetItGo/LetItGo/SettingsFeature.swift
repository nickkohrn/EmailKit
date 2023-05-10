import ComposableArchitecture
import Foundation
import PurchasesKit
import RevenueCat

struct SettingsFeature: ReducerProtocol {
    enum ProductPurchaseState: Equatable {
        case notPurchasing
        case purchasing(PurchasableProduct)
    }

    struct State: Equatable {
        @BindingState var enableHapticFeedback = false
        var accentColorSelection: AccentColorSelectionFeature.State?
        var isAccentColorSelectionActive = false
        var selectedAccentColor: AccentColorSelection = .blue
        var canMakePayments = false
        var tipProducts = [PurchasableProduct]()
        var productPurchaseState = ProductPurchaseState.notPurchasing

        var isMakingPurchase: Bool {
            if case .purchasing = productPurchaseState {
                return true
            }
            return false
        }
    }

    enum Action: Equatable, BindableAction {
        enum DelegateAction: Equatable {
            case dismiss
        }

        case accentColorSelection(AccentColorSelectionFeature.Action)
        case accentColorSelectionDismissed
        case accentColorSelectionTapped
        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case dismissButtonActivated
        case onAppear
        case purchasableProductTapped(PurchasableProduct)
        case receivedCanMakePaymentsResponse(TaskResult<Bool>)
        case receivedPurchaseCancelledByUserResponse
        case receivedPurchaseFailedResponse
        case receivedPurchaseSuccessResponse
        case receivedTipProducts(TaskResult<[PurchasableProduct]>)
        case submitReviewButtonActivated
    }

    @Dependency(\.purchasesClient) var purchasesClient
    @Dependency(\.openURL) var openURL
    @Dependency(\.userDefaults) var userDefaults

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {

            case .accentColorSelectionDismissed:
                state.accentColorSelection = nil
                return .none

            case .accentColorSelectionTapped:
                state.accentColorSelection = .init()
                return .none

            case .accentColorSelection(.delegate(.selectedAccentColor)):
                state.selectedAccentColor = userDefaults.selectedAccentColor
                return .none

            case .accentColorSelection:
                return .none

            case .binding(\.$enableHapticFeedback):
                return .fireAndForget { [enabled = state.enableHapticFeedback] in
                    await userDefaults.setEnableHapticFeedback(enabled)
                }

            case .binding:
                return .none

            case .delegate:
                return .none

            case .dismissButtonActivated:
                return EffectTask(value: .delegate(.dismiss))

            case .onAppear:
                state.selectedAccentColor = userDefaults.selectedAccentColor
                state.enableHapticFeedback = userDefaults.enableHapticFeedback
                return .task(priority: .high) {
                    await .receivedCanMakePaymentsResponse(
                        TaskResult {
                            await purchasesClient.canMakePayments()
                        }
                    )
                }

            case .purchasableProductTapped(let product):
                guard let storeProduct = product.storeProduct else {
                    print("Expected \(StoreProduct.self)")
                    return .none
                }
                state.productPurchaseState = .purchasing(product)
                return .run(priority: .userInitiated) { send in
                    let purchaseResultData = try await purchasesClient.purchaseProduct(storeProduct)
                    if purchaseResultData.userCancelled {

                    } else {
                        await send(.receivedPurchaseSuccessResponse)
                    }
                } catch: { error, send in
                    await send(.receivedPurchaseFailedResponse)
                }

            case .receivedCanMakePaymentsResponse(.failure(let error)):
                print("Can make payments: \(error.localizedDescription)")
                state.canMakePayments = false
                return .none

            case .receivedCanMakePaymentsResponse(.success(let canMakePayments)):
                print("Can make payments: \(canMakePayments)")
                state.canMakePayments = canMakePayments
                guard canMakePayments else { return .none }
                return .task(priority: .high) {
                    await .receivedTipProducts(
                        TaskResult {
                            await purchasesClient.products(["com.nickkohrn.LetItGo.SmallTip"])
                        }
                    )
                }

            case .receivedPurchaseCancelledByUserResponse:
                state.productPurchaseState = .notPurchasing
                return .none

            case .receivedPurchaseFailedResponse:
                state.productPurchaseState = .notPurchasing
                return .none

            case .receivedPurchaseSuccessResponse:
                state.productPurchaseState = .notPurchasing
                return .none

            case .receivedTipProducts(.failure(let error)):
                print("Tip products: \(error.localizedDescription)")
                state.tipProducts.removeAll()
                return .none

            case .receivedTipProducts(.success(let tipProducts)):
                print("Tip products: \(tipProducts)")
                state.tipProducts = tipProducts
                return .none

            case .submitReviewButtonActivated:
                guard let url = URL(string: "https://apps.apple.com/us/app/let-it-go/id6448896506") else {
                    print("Expected \(URL.self)")
                    return .none
                }
                return .fireAndForget { await openURL(url) }

            }
        }
        .ifLet(\.accentColorSelection, action: /Action.accentColorSelection) {
            AccentColorSelectionFeature()
        }
    }
}
