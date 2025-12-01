// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Stride",
    platforms: [
        .iOS(.v17)   // プロジェクトの Deployment Target に合わせて変えてOK
    ],
    products: [
        // VSCode で解析しやすくするためのライブラリ扱い
        .library(
            name: "StrideCore",
            targets: ["Stride"]
        ),
        .library(
            name: "StrideWidgetCore",
            targets: ["StrideWidget"]
        ),
    ],
    dependencies: [
        // 外部パッケージを使っていればここに .package(url:..., from: ...) を追加
    ],
    targets: [
        // アプリ本体のコード
        .target(
            name: "Stride",
            path: "Stride",
            // @main struct StrideApp: App が入っているファイルは
            // ライブラリターゲットから除外する
            exclude: [
                "StrideApp.swift"   // 実際のファイル名に合わせてください
            ]
        ),

        // Widget のコード
        .target(
            name: "StrideWidget",
            dependencies: ["Stride"],
            path: "StrideWidget",
            exclude: [
                "StrideWidgetBundle.swift"
            ]
        ),

        // 単体テスト
        .testTarget(
            name: "StrideTests",
            dependencies: ["Stride"],
            path: "StrideTests"
        )
        // UI テストは SwiftPM 経由では基本使わないので省略でOK
    ]
)
