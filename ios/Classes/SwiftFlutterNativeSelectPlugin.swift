import Flutter
import UIKit

private struct NativeSelectItem: Decodable {
    let value: String
    let label: String
    let disabled: Bool
    let color: Int?
}

private struct OpenSelectArguments: Decodable {
    let items: [NativeSelectItem]
    let defaultValue: String
    let doneText: String
    let clearText: String?
}

private let decoder = JSONDecoder()
private var activeController: PickerViewController?

public class SwiftFlutterNativeSelectPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_native_select", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterNativeSelectPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "openSelect" else {
            result(FlutterMethodNotImplemented)
            return
        }

        handleOpenSelect(arguments: try! decoder.decode(OpenSelectArguments.self, from: (call.arguments as! String).data(using: .utf8)!), result: result)
    }

    private func handleOpenSelect(arguments: OpenSelectArguments, result: @escaping FlutterResult) {
        activeController?.onClear()

        let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        guard var topController = keyWindow?.rootViewController else { return }
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        let pickerView = UIPickerView()

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.isUserInteractionEnabled = true

        let inputField = UITextField()
        inputField.inputView = pickerView
        inputField.inputAccessoryView = toolbar

        let controller = PickerViewController(arguments.items, inputField, topController.view, arguments.defaultValue, result)
        pickerView.delegate = controller
        pickerView.dataSource = controller
        pickerView.selectRow(arguments.items.firstIndex { $0.value == arguments.defaultValue } ?? 0, inComponent: 0, animated: false)
        activeController = controller

        let doneButton = UIBarButtonItem(title: arguments.doneText, style: .done, target: controller, action: #selector(PickerViewController.onDone))

        if let clearText = arguments.clearText {
            let clearButton = UIBarButtonItem(title: clearText, style: .plain, target: controller, action: #selector(PickerViewController.onClear))
            toolbar.setItems([doneButton, clearButton], animated: true)
        } else {
            toolbar.setItems([doneButton], animated: true)
        }

        topController.view.addSubview(inputField)
        inputField.becomeFirstResponder()
    }
}

private class PickerViewController: NSObject {
    let items: [NativeSelectItem]
    let inputField: UITextField
    let containerView: UIView
    let result: FlutterResult

    var selectedValue: String?

    init(_ items: [NativeSelectItem], _ inputField: UITextField, _ containerView: UIView, _ defaultValue: String, _ result: @escaping FlutterResult) {
        self.items = items
        self.inputField = inputField
        self.containerView = containerView
        self.selectedValue = defaultValue
        self.result = result
    }

    @objc
    func onDone() {
        close()
        result(selectedValue)
    }

    @objc
    func onClear() {
        close()
        result(nil)
    }

    private func close() {
        containerView.endEditing(true)
        inputField.resignFirstResponder()
        inputField.removeFromSuperview()
        activeController = nil
    }
}

extension PickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let item = items[row]
        if item.disabled {
            var targetRow = row
            while targetRow > 0 {
                targetRow -= 1
                if !items[targetRow].disabled {
                    pickerView.selectRow(targetRow, inComponent: 0, animated: true)
                    return
                }
            }

            targetRow = row
            while targetRow < items.count - 1 {
                targetRow += 1
                if !items[targetRow].disabled {
                    pickerView.selectRow(targetRow, inComponent: 0, animated: true)
                    return
                }
            }
        } else {
            selectedValue = item.value
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].label
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let item = items[row]
        if item.color == nil && !item.disabled { return nil }
        let color = item.color
        var uiColor = color.map { UIColor(value: $0) }
        if uiColor == nil {
            if #available(iOS 13.0, *) {
                uiColor = UIColor.label
            } else {
                uiColor = UIColor.darkText
            }
        }

        if item.disabled {
            uiColor = uiColor?.withAlphaComponent(0.4)
        }

        return NSAttributedString(string: item.label, attributes: [ NSAttributedString.Key.foregroundColor: uiColor! ])
    }
}

extension PickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
}

private extension UIColor {
    convenience init(value: Int) {
        self.init(red: CGFloat(value >> 16 & 0xff) / 255, green: CGFloat(value >> 8 & 0xff) / 255, blue: CGFloat(value & 0xff) / 255, alpha: CGFloat(value >> 24 & 0xff) / 255)
    }
}
