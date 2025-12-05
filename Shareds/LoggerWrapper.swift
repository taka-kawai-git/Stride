import OSLog

extension Logger {
    static let strideSubsystem = "com.gmail.dev.apps.taka.Stride"

    /// Stride用のサブシステムを固定したイニシャライザ
    init(category: String) {
        self.init(subsystem: Logger.strideSubsystem, category: category)
    }

    /// 呼び出し元のファイル名と関数名を自動付与するカスタムログ出力
    func tDebug(_ message: String, file: String = #fileID, function: String = #function) {
        log(level: .debug, message: message, file: file, function: function)
    }

    func tInfo(_ message: String, file: String = #fileID, function: String = #function) {
        log(level: .info, message: message, file: file, function: function)
    }

    func tError(_ message: String, file: String = #fileID, function: String = #function) {
        log(level: .error, message: message, file: file, function: function)
    }

    func tFault(_ message: String, file: String = #fileID, function: String = #function) {
        log(level: .fault, message: message, file: file, function: function)
    }

    // 共通のログ出力処理
    private func log(level: OSLogType, message: String, file: String, function: String) {
        // ファイルパスから "StepViewModel.swift" のようなファイル名部分だけを抽出
        // さらに ".swift" を除去してクラス名っぽく見せる
        let fileName = file.components(separatedBy: "/").last?.replacingOccurrences(of: ".swift", with: "") ?? ""
        
        // ログ出力フォーマット: [ClassName functionName] Message
        let logMessage = "[\(fileName) \(function)] \(message)"
        
        self.log(level: level, "\(logMessage, privacy: .public)")
    }
}
