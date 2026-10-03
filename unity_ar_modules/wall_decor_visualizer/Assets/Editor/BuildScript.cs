using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

public class BuildScript
{
    public static void BuildAndroid()
    {
        Debug.Log("[BuildScript] Starting Android APK build for AR Wall Decor Visualizer...");

        PlayerSettings.SetApplicationIdentifier(UnityEditor.Build.NamedBuildTarget.Android, "com.Intario_Ai.arwalldecor");
        PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel24;

        if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android)
        {
            Debug.Log("[BuildScript] Switching active build target to Android...");
            EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
        }

        EditorUserBuildSettings.exportAsGoogleAndroidProject = false;

        string[] scenes = { "Assets/Scenes/SampleScene.unity" };
        string outputPath = "E:/AR_Wall_Decor Visualizer/ARWallDecor.apk";

        BuildPlayerOptions buildPlayerOptions = new BuildPlayerOptions
        {
            scenes = scenes,
            locationPathName = outputPath,
            target = BuildTarget.Android,
            options = BuildOptions.None
        };

        BuildReport report = BuildPipeline.BuildPlayer(buildPlayerOptions);
        BuildSummary summary = report.summary;

        if (summary.result == BuildResult.Succeeded)
        {
            Debug.Log($"[BuildScript] Build succeeded: {summary.totalSize} bytes at {outputPath}");
            EditorApplication.Exit(0);
        }
        else
        {
            Debug.LogError($"[BuildScript] Build failed with result: {summary.result}, errors: {summary.totalErrors}");
            EditorApplication.Exit(1);
        }
    }
}
