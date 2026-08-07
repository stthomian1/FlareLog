import os

def create_xcodeproj():
    xcodeproj_dir = "FlareLog.xcodeproj"
    os.makedirs(xcodeproj_dir, exist_ok=True)
    
    # We will write a complete, valid project.pbxproj file
    pbxproj_path = os.path.join(xcodeproj_dir, "project.pbxproj")
    
    content = """// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 55;
	objects = {

/* Begin PBXBuildFile section */
		D37F00012A5E0B0100000001 /* FlareLogApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10012A5E0B0100000001 /* FlareLogApp.swift */; };
		D37F00022A5E0B0200000002 /* DatabaseModels.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10022A5E0B0200000002 /* DatabaseModels.swift */; };
		D37F00032A5E0B0300000003 /* HealthKitService.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10032A5E0B0300000003 /* HealthKitService.swift */; };
		D37F00042A5E0B0400000004 /* SubscriptionManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10042A5E0B0400000004 /* SubscriptionManager.swift */; };
		D37F00052A5E0B0500000005 /* PDFExportService.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10052A5E0B0500000005 /* PDFExportService.swift */; };
		D37F00062A5E0B0600000006 /* DisclaimerView.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10062A5E0B0600000006 /* DisclaimerView.swift */; };
		D37F00072A5E0B0700000007 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10072A5E0B0700000007 /* ContentView.swift */; };
		D37F00082A5E0B0800000008 /* DailyLogView.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10082A5E0B0800000008 /* DailyLogView.swift */; };
		D37F00092A5E0B0900000009 /* PatternsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F10092A5E0B0900000009 /* PatternsView.swift */; };
		D37F000A2A5E0B0A0000000A /* PaywallView.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F100A2A5E0B0A0000000A /* PaywallView.swift */; };
		D37F000B2A5E0B0B0000000B /* SettingsView.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F100B2A5E0B0B0000000B /* SettingsView.swift */; };
		D37F000E2A5E0B0E0000000E /* HelpSheetView.swift in Sources */ = {isa = PBXBuildFile; fileRef = D37F100E2A5E0B0E0000000E /* HelpSheetView.swift */; };
		D37F000F2A5E0B0F0000000F /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = D37F100F2A5E0B0F0000000F /* Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		D37F10012A5E0B0100000001 /* FlareLogApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = FlareLogApp.swift; path = FlareLog/FlareLogApp.swift; sourceTree = "<group>"; };
		D37F10022A5E0B0200000002 /* DatabaseModels.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = DatabaseModels.swift; path = FlareLog/Models/DatabaseModels.swift; sourceTree = "<group>"; };
		D37F10032A5E0B0300000003 /* HealthKitService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = HealthKitService.swift; path = FlareLog/Services/HealthKitService.swift; sourceTree = "<group>"; };
		D37F10042A5E0B0400000004 /* SubscriptionManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = SubscriptionManager.swift; path = FlareLog/Services/SubscriptionManager.swift; sourceTree = "<group>"; };
		D37F10052A5E0B0500000005 /* PDFExportService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = PDFExportService.swift; path = FlareLog/Services/PDFExportService.swift; sourceTree = "<group>"; };
		D37F10062A5E0B0600000006 /* DisclaimerView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = DisclaimerView.swift; path = FlareLog/Views/DisclaimerView.swift; sourceTree = "<group>"; };
		D37F10072A5E0B0700000007 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = ContentView.swift; path = FlareLog/Views/ContentView.swift; sourceTree = "<group>"; };
		D37F10082A5E0B0800000008 /* DailyLogView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = DailyLogView.swift; path = FlareLog/Views/DailyLogView.swift; sourceTree = "<group>"; };
		D37F10092A5E0B0900000009 /* PatternsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = PatternsView.swift; path = FlareLog/Views/PatternsView.swift; sourceTree = "<group>"; };
		D37F100A2A5E0B0A0000000A /* PaywallView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = PaywallView.swift; path = FlareLog/Views/PaywallView.swift; sourceTree = "<group>"; };
		D37F100B2A5E0B0B0000000B /* SettingsView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = SettingsView.swift; path = FlareLog/Views/SettingsView.swift; sourceTree = "<group>"; };
		D37F100E2A5E0B0E0000000E /* HelpSheetView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = HelpSheetView.swift; path = FlareLog/Views/HelpSheetView.swift; sourceTree = "<group>"; };
		D37F100C2A5E0B0C0000000C /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; name = Info.plist; path = FlareLog/Info.plist; sourceTree = "<group>"; };
		D37F100D2A5E0B0D0000000D /* FlareLog.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; name = FlareLog.entitlements; path = FlareLog/FlareLog.entitlements; sourceTree = "<group>"; };
		D37F100F2A5E0B0F0000000F /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; name = Assets.xcassets; path = FlareLog/Assets.xcassets; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		D37F20012A5E0B0100000001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		D37F30012A5E0B0100000001 = {
			isa = PBXGroup;
			children = (
				D37F30022A5E0B0100000001 /* FlareLog */,
				D37F30032A5E0B0100000001 /* Products */,
			);
			sourceTree = "<group>";
		};
		D37F30022A5E0B0100000001 /* FlareLog */ = {
			isa = PBXGroup;
			children = (
				D37F10012A5E0B0100000001 /* FlareLogApp.swift */,
				D37F30042A5E0B0100000001 /* Models */,
				D37F30052A5E0B0100000001 /* Services */,
				D37F30062A5E0B0100000001 /* Views */,
				D37F100F2A5E0B0F0000000F /* Assets.xcassets */,
				D37F100C2A5E0B0C0000000C /* Info.plist */,
				D37F100D2A5E0B0D0000000D /* FlareLog.entitlements */,
			);
			name = FlareLog;
			sourceTree = "<group>";
		};
		D37F30042A5E0B0100000001 /* Models */ = {
			isa = PBXGroup;
			children = (
				D37F10022A5E0B0200000002 /* DatabaseModels.swift */,
			);
			name = Models;
			sourceTree = "<group>";
		};
		D37F30052A5E0B0100000001 /* Services */ = {
			isa = PBXGroup;
			children = (
				D37F10032A5E0B0300000003 /* HealthKitService.swift */,
				D37F10042A5E0B0400000004 /* SubscriptionManager.swift */,
				D37F10052A5E0B0500000005 /* PDFExportService.swift */,
			);
			name = Services;
			sourceTree = "<group>";
		};
		D37F30062A5E0B0100000001 /* Views */ = {
			isa = PBXGroup;
			children = (
				D37F10062A5E0B0600000006 /* DisclaimerView.swift */,
				D37F10072A5E0B0700000007 /* ContentView.swift */,
				D37F10082A5E0B0800000008 /* DailyLogView.swift */,
				D37F10092A5E0B0900000009 /* PatternsView.swift */,
				D37F100A2A5E0B0A0000000A /* PaywallView.swift */,
				D37F100B2A5E0B0B0000000B /* SettingsView.swift */,
				D37F100E2A5E0B0E0000000E /* HelpSheetView.swift */,
			);
			name = Views;
			sourceTree = "<group>";
		};
		D37F30032A5E0B0100000001 /* Products */ = {
			isa = PBXGroup;
			children = (
				D37F40012A5E0B0100000001 /* FlareLog.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		D37F50012A5E0B0100000001 /* FlareLog */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = D37F60012A5E0B0100000001 /* Build configuration list for PBXNativeTarget "FlareLog" */;
			buildPhases = (
				D37F70012A5E0B0100000001 /* Sources */,
				D37F20012A5E0B0100000001 /* Frameworks */,
				D37F80012A5E0B0100000001 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = FlareLog;
			packageProductDependencies = (
				D37F90022A5E0B0D00000002 /* FlareLogCore */,
			);
			productName = FlareLog;
			productReference = D37F40012A5E0B0100000001 /* FlareLog.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		D37FA0012A5E0B0100000001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				LastSwiftUpdateCheck = 1420;
				LastUpgradeCheck = 1420;
				TargetAttributes = {
					D37F50012A5E0B0100000001 = {
						CreatedOnToolsVersion = 14.2;
					};
				};
			};
			buildConfigurationList = D37FB0012A5E0B0100000001 /* Build configuration list for PBXProject "FlareLog" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = D37F30012A5E0B0100000001;
			packageReferences = (
				D37F90012A5E0B0C00000001 /* XCLocalSwiftPackageReference "FlareLogCore" */,
			);
			productRefGroup = D37F30032A5E0B0100000001 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				D37F50012A5E0B0100000001 /* FlareLog */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		D37F80012A5E0B0100000001 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				D37F000F2A5E0B0F0000000F /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		D37F70012A5E0B0100000001 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				D37F00012A5E0B0100000001 /* FlareLogApp.swift in Sources */,
				D37F00022A5E0B0200000002 /* DatabaseModels.swift in Sources */,
				D37F00032A5E0B0300000003 /* HealthKitService.swift in Sources */,
				D37F00042A5E0B0400000004 /* SubscriptionManager.swift in Sources */,
				D37F00052A5E0B0500000005 /* PDFExportService.swift in Sources */,
				D37F00062A5E0B0600000006 /* DisclaimerView.swift in Sources */,
				D37F00072A5E0B0700000007 /* ContentView.swift in Sources */,
				D37F00082A5E0B0800000008 /* DailyLogView.swift in Sources */,
				D37F00092A5E0B0900000009 /* PatternsView.swift in Sources */,
				D37F000A2A5E0B0A0000000A /* PaywallView.swift in Sources */,
				D37F000B2A5E0B0B0000000B /* SettingsView.swift in Sources */,
				D37F000E2A5E0B0E0000000E /* HelpSheetView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		D37FC0012A5E0B0100000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = FlareLog/FlareLog.entitlements;
				CODE_SIGN_STYLE = Manual;
				CURRENT_PROJECT_VERSION = 21;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				INFOPLIST_FILE = FlareLog/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stthomian1.FlareLog;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.7;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		D37FC0022A5E0B0100000002 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = FlareLog/FlareLog.entitlements;
				CODE_SIGN_STYLE = Manual;
				CURRENT_PROJECT_VERSION = 21;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				INFOPLIST_FILE = FlareLog/Info.plist;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.stthomian1.FlareLog;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.7;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
		D37FD0012A5E0B0100000001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_REPRODUCIBLE_ACTIONS = YES;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_ACTUAL = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		D37FD0022A5E0B0100000002 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_CXX_LIBRARY = "libc++";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_REPRODUCIBLE_ACTIONS = YES;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = YES;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_ACTUAL = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		D37F60012A5E0B0100000001 /* Build configuration list for PBXNativeTarget "FlareLog" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				D37FC0012A5E0B0100000001 /* Debug */,
				D37FC0022A5E0B0100000002 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		D37FB0012A5E0B0100000001 /* Build configuration list for PBXProject "FlareLog" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				D37FD0012A5E0B0100000001 /* Debug */,
				D37FD0022A5E0B0100000002 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */

/* Begin XCLocalSwiftPackageReference section */
		D37F90012A5E0B0C00000001 /* XCLocalSwiftPackageReference "FlareLogCore" */ = {
			isa = XCLocalSwiftPackageReference;
			relativePath = FlareLogCore;
		};
/* End XCLocalSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
		D37F90022A5E0B0D00000002 /* FlareLogCore */ = {
			isa = XCSwiftPackageProductDependency;
			package = D37F90012A5E0B0C00000001 /* XCLocalSwiftPackageReference "FlareLogCore" */;
			productName = FlareLogCore;
		};
/* End XCSwiftPackageProductDependency section */

/* Begin PBXFileReference section */
		D37F40012A5E0B0100000001 /* FlareLog.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = FlareLog.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */
	};
	rootObject = D37FA0012A5E0B0100000001 /* Project object */;
}
"""
    with open(pbxproj_path, "w") as f:
        f.write(content)
    print("Successfully generated FlareLog.xcodeproj/project.pbxproj")

if __name__ == "__main__":
    create_xcodeproj()
