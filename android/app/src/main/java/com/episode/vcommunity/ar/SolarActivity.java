/*
 * Copyright 2018 Google LLC.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.episode.vcommunity.ar;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import androidx.annotation.NonNull;
import com.google.android.material.snackbar.Snackbar;
import androidx.appcompat.app.AppCompatActivity;

import android.util.Log;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import com.episode.vcommunity.R;
import com.google.ar.core.Anchor;
import com.google.ar.core.Config;
import com.google.ar.core.Frame;
import com.google.ar.core.HitResult;
import com.google.ar.core.Plane;
import com.google.ar.core.Session;
import com.google.ar.core.Trackable;
import com.google.ar.core.TrackingState;
import com.google.ar.core.exceptions.CameraNotAvailableException;
import com.google.ar.core.exceptions.UnavailableException;
import com.google.ar.sceneform.AnchorNode;
import com.google.ar.sceneform.ArSceneView;
import com.google.ar.sceneform.HitTestResult;
import com.google.ar.sceneform.Node;
import com.google.ar.sceneform.math.Vector3;
import com.google.ar.sceneform.rendering.ModelRenderable;
import com.google.ar.sceneform.rendering.Renderable;
import com.google.ar.sceneform.rendering.ViewRenderable;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

/**
 * This is a simple example that shows how to create an augmented reality (AR) application using the
 * ARCore and Sceneform APIs.
 */
public class SolarActivity extends AppCompatActivity {

  private static final String KEY_BLOGLIST = "KEY_BLOGLIST";

  private static final int BLOG_COUNT_MIN = 3;

  private static final int RC_PERMISSIONS = 0x123;
  private boolean cameraPermissionRequested;

  private GestureDetector gestureDetector;
  private Snackbar loadingMessageSnackbar = null;

  private ArSceneView arSceneView;

  private ModelRenderable sunRenderable;
  private ViewRenderable solarControlsRenderable;

  private final SolarSettings solarSettings = new SolarSettings();

  // True once scene is loaded
  private boolean hasFinishedLoading = false;

  // True once the scene has been placed.
  private boolean hasPlacedSolarSystem = false;

  // Astronomical units to meters ratio. Used for positioning the planets of the solar system.
  private static final float AU_TO_METERS = 0.5f;

  List<Blog> blogList = new ArrayList<>();
  List<ModelRenderable> surroundingBlogRenderableList = new ArrayList<>();

  public static void startActivity(Context context, String blogList) {
    Intent intent = new Intent(context, SolarActivity.class);
    intent.putExtra(KEY_BLOGLIST, blogList);
    context.startActivity(intent);
  }

  @Override
  @SuppressWarnings({"AndroidApiChecker", "FutureReturnValueIgnored"})
  // CompletableFuture requires api level 24
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    if (!DemoUtils.checkIsSupportedDeviceOrFinish(this)) {
      // Not a supported device.
      return;
    }

    String blogListStr = getIntent().getStringExtra(KEY_BLOGLIST);
    if (blogListStr == null || blogListStr.isEmpty()) {
      DemoUtils.displayError(this, "没有列表数据", null);
      finish();
      return;
    }
    JsonArray jsonArray = JsonParser.parseString(blogListStr).getAsJsonArray();
    for (JsonElement jsonElement : jsonArray) {
        blogList.add(new Gson().fromJson(((JsonObject) jsonElement).get("data"), Blog.class));
    }
    if (blogList.isEmpty()) {
      DemoUtils.displayError(this, "没有列表数据2", null);
      finish();
      return;
    }
    if (blogList.size() < BLOG_COUNT_MIN) {
      DemoUtils.displayError(this, "数据过少", null);
      finish();
      return;
    }
    Iterator<Blog> iterator = blogList.iterator();
    while (iterator.hasNext()) {
      Blog blog = iterator.next();
      String content = blog.content;
      JsonArray contentArray = JsonParser.parseString(content).getAsJsonArray();
      JsonElement jsonElement = contentArray.get(0).getAsJsonObject().get("insert");
      if (jsonElement.isJsonPrimitive() && jsonElement.getAsJsonPrimitive().isString()) {
        blog.content = jsonElement.getAsString();
      } else {
        iterator.remove();
      }
    }

    setContentView(R.layout.activity_solar);
    arSceneView = findViewById(R.id.ar_scene_view);

    // Build all the planet models.
    List<CompletableFuture<? extends Renderable>> renderableFutureList = new ArrayList<>();
    CompletableFuture<ModelRenderable> centerBlogModelRenderableFuture =
            ModelRenderable.builder().setSource(this, Uri.parse("line_transparent.sfb")).build();
    renderableFutureList.add(centerBlogModelRenderableFuture);
    for (int i = 0; i < blogList.size() - 1; i++) {
      renderableFutureList.add(
              ModelRenderable.builder().setSource(this, Uri.parse("line_transparent.sfb")).build());
    }

    // Build a renderable from a 2D View.
    CompletableFuture<ViewRenderable> centerBlogViewRenderableFuture =
        ViewRenderable.builder().setView(this, R.layout.ar_item_view).build();
    renderableFutureList.add(centerBlogViewRenderableFuture);

    CompletableFuture.allOf(renderableFutureList.toArray(new CompletableFuture[0]))
        .handle(
            (notUsed, throwable) -> {
              // When you build a Renderable, Sceneform loads its resources in the background while
              // returning a CompletableFuture. Call handle(), thenAccept(), or check isDone()
              // before calling get().

              if (throwable != null) {
                DemoUtils.displayError(this, "Unable to load renderable", throwable);
                return null;
              }

              try {
                sunRenderable = centerBlogModelRenderableFuture.get();
                List<CompletableFuture<? extends Renderable>> surroundingBlogRenderFutureList = renderableFutureList.subList(1, renderableFutureList.size() - 1);
                for (CompletableFuture<? extends Renderable> future : surroundingBlogRenderFutureList) {
                  surroundingBlogRenderableList.add((ModelRenderable) future.get());
                }
                solarControlsRenderable = centerBlogViewRenderableFuture.get();

                // Everything finished loading successfully.
                hasFinishedLoading = true;

              } catch (InterruptedException | ExecutionException ex) {
                DemoUtils.displayError(this, "Unable to load renderable", ex);
              }

              return null;
            });

    // Set up a tap gesture detector.
    gestureDetector =
        new GestureDetector(
            this,
            new GestureDetector.SimpleOnGestureListener() {
              @Override
              public boolean onSingleTapUp(@NonNull MotionEvent e) {
                onSingleTap(e);
                return true;
              }

              @Override
              public boolean onDown(@NonNull MotionEvent e) {
                return true;
              }
            });

    // Set a touch listener on the Scene to listen for taps.
    arSceneView
        .getScene()
        .setOnTouchListener(
            (HitTestResult hitTestResult, MotionEvent event) -> {
              // If the solar system hasn't been placed yet, detect a tap and then check to see if
              // the tap occurred on an ARCore plane to place the solar system.
              if (!hasPlacedSolarSystem) {
                return gestureDetector.onTouchEvent(event);
              }

              // Otherwise return false so that the touch event can propagate to the scene.
              return false;
            });

    // Set an update listener on the Scene that will hide the loading message once a Plane is
    // detected.
    arSceneView
        .getScene()
        .addOnUpdateListener(
            frameTime -> {
              if (loadingMessageSnackbar == null) {
                return;
              }

              Frame frame = arSceneView.getArFrame();
              if (frame == null) {
                return;
              }

              if (frame.getCamera().getTrackingState() != TrackingState.TRACKING) {
                return;
              }

              for (Plane plane : frame.getUpdatedTrackables(Plane.class)) {
                if (plane.getTrackingState() == TrackingState.TRACKING) {
                  hideLoadingMessage();
                }
              }
            });

    // Lastly request CAMERA permission which is required by ARCore.
    DemoUtils.requestCameraPermission(this, RC_PERMISSIONS);
  }

  @Override
  protected void onResume() {
    super.onResume();
    if (arSceneView == null) {
      return;
    }

    if (arSceneView.getSession() == null) {
      // If the session wasn't created yet, don't resume rendering.
      // This can happen if ARCore needs to be updated or permissions are not granted yet.
      try {
        Config.LightEstimationMode lightEstimationMode =
            Config.LightEstimationMode.ENVIRONMENTAL_HDR;
        Session session =
            cameraPermissionRequested
                ? DemoUtils.createArSessionWithInstallRequest(this, lightEstimationMode)
                : DemoUtils.createArSessionNoInstallRequest(this, lightEstimationMode);
        if (session == null) {
          cameraPermissionRequested = DemoUtils.hasCameraPermission(this);
          return;
        } else {
          arSceneView.setupSession(session);
        }
      } catch (UnavailableException e) {
        DemoUtils.handleSessionException(this, e);
      }
    }

    try {
      arSceneView.resume();
    } catch (CameraNotAvailableException ex) {
      DemoUtils.displayError(this, "Unable to get camera", ex);
      finish();
      return;
    }

    if (arSceneView.getSession() != null) {
      showLoadingMessage();
    }
  }

  @Override
  public void onPause() {
    super.onPause();
    if (arSceneView != null) {
      arSceneView.pause();
    }
  }

  @Override
  public void onDestroy() {
    super.onDestroy();
    if (arSceneView != null) {
      arSceneView.destroy();
    }
  }

  @Override
  public void onRequestPermissionsResult(
      int requestCode, @NonNull String[] permissions, @NonNull int[] results) {
    if (!DemoUtils.hasCameraPermission(this)) {
      if (!DemoUtils.shouldShowRequestPermissionRationale(this)) {
        // Permission denied with checking "Do not ask again".
        DemoUtils.launchPermissionSettings(this);
      } else {
        Toast.makeText(
                this, "Camera permission is needed to run this application", Toast.LENGTH_LONG)
            .show();
      }
      finish();
    }
  }

  @Override
  public void onWindowFocusChanged(boolean hasFocus) {
    super.onWindowFocusChanged(hasFocus);
    if (hasFocus) {
      // Standard Android full-screen functionality.
      getWindow()
          .getDecorView()
          .setSystemUiVisibility(
              View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                  | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                  | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                  | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                  | View.SYSTEM_UI_FLAG_FULLSCREEN
                  | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY);
      getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }
  }

  private void onSingleTap(MotionEvent tap) {
    if (!hasFinishedLoading) {
      Log.e("SolarActivity", "hasFinishedLoading");
      // We can't do anything yet.
      return;
    }

    Frame frame = arSceneView.getArFrame();
    if (frame != null) {
      Log.e("SolarActivity", "11111111111");
      if (!hasPlacedSolarSystem && tryPlaceSolarSystem(tap, frame)) {
        hasPlacedSolarSystem = true;
      }
    }
  }

  private boolean tryPlaceSolarSystem(MotionEvent tap, Frame frame) {
    Log.e("SolarActivity", "22222222222222222222");
    if (tap != null && frame.getCamera().getTrackingState() == TrackingState.TRACKING) {
      for (HitResult hit : frame.hitTest(tap)) {
        Trackable trackable = hit.getTrackable();
        if (trackable instanceof Plane && ((Plane) trackable).isPoseInPolygon(hit.getHitPose())) {
          // Create the Anchor.
          Anchor anchor = hit.createAnchor();
          AnchorNode anchorNode = new AnchorNode(anchor);
          anchorNode.setParent(arSceneView.getScene());
          Node solarSystem = createSolarSystem();
          anchorNode.addChild(solarSystem);
          return true;
        }
      }
    }

    return false;
  }

  private Node createSolarSystem() {
    Node base = new Node();

    Node sun = new Node();
    sun.setParent(base);
    sun.setLocalPosition(new Vector3(0.0f, 0.5f, 0.0f));

    Node sunVisual = new Node();
    sunVisual.setParent(sun);
    sunVisual.setRenderable(sunRenderable);
    sunVisual.setLocalScale(new Vector3(0.5f, 0.5f, 0.5f));

    Node solarControls = new Node();
    solarControls.setParent(sun);
    solarControls.setRenderable(solarControlsRenderable);
    solarControls.setLocalPosition(new Vector3(0.0f, 0.25f, 0.0f));

    Blog centerBlog = blogList.get(0);
    View solarControlsView = solarControlsRenderable.getView();
    ImageView userAvatarView = solarControlsView.findViewById(R.id.user_avatar);
    Picasso.get().load(centerBlog.user.icon).into(userAvatarView);
    ((TextView) solarControlsView.findViewById(R.id.user_name)).setText(centerBlog.user.nickName);
    ((TextView) solarControlsView.findViewById(R.id.blog_title)).setText(centerBlog.title);
    ((TextView) solarControlsView.findViewById(R.id.blog_content)).setText(centerBlog.content);

    for (int i = 0; i < surroundingBlogRenderableList.size(); i++) {
      createPlanet(sun, randomFloat(1f, 10.0f), randomInt(5, 30), surroundingBlogRenderableList.get(i),
              randomFloat(0.018f, 0.16f), randomFloat(0.03f, 80.0f), blogList.get(i++));
    }

    return base;
  }

  private void createPlanet(
      Node parent,
      float auFromParent,
      float orbitDegreesPerSecond,
      ModelRenderable renderable,
      float planetScale,
      float axisTilt,
      Blog blog) {
    // Orbit is a rotating node with no renderable positioned at the sun.
    // The planet is positioned relative to the orbit so that it appears to rotate around the sun.
    // This is done instead of making the sun rotate so each planet can orbit at its own speed.
    RotatingNode orbit = new RotatingNode(solarSettings, true, false, 0);
    orbit.setDegreesPerSecond(orbitDegreesPerSecond);
    orbit.setParent(parent);

    // Create the planet and position it relative to the sun.
    Planet planet =
        new Planet(
            this, planetScale, orbitDegreesPerSecond, axisTilt, renderable, solarSettings, blog);
    planet.setParent(orbit);
    planet.setLocalPosition(new Vector3(auFromParent * AU_TO_METERS, 0.0f, 0.0f));
  }

  private void showLoadingMessage() {
    if (loadingMessageSnackbar != null && loadingMessageSnackbar.isShownOrQueued()) {
      return;
    }

    loadingMessageSnackbar =
        Snackbar.make(
            SolarActivity.this.findViewById(android.R.id.content),
            R.string.plane_finding,
            Snackbar.LENGTH_INDEFINITE);
    loadingMessageSnackbar.getView().setBackgroundColor(0xbf323232);
    loadingMessageSnackbar.show();
  }

  private void hideLoadingMessage() {
    if (loadingMessageSnackbar == null) {
      return;
    }

    loadingMessageSnackbar.dismiss();
    loadingMessageSnackbar = null;
  }

  private static float randomFloat(float min, float max) {
    return min + ((max - min) * new Random().nextFloat());
  }

  private static int randomInt(int min, int max) {
    return new Random().nextInt((max - min) + 1) + min;
  }

}
