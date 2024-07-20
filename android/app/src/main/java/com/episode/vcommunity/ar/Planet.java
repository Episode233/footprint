/*
 * Copyright 2018 Google LLC
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
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import com.episode.vcommunity.R;
import com.google.ar.sceneform.FrameTime;
import com.google.ar.sceneform.Node;
import com.google.ar.sceneform.math.Quaternion;
import com.google.ar.sceneform.math.Vector3;
import com.google.ar.sceneform.rendering.ModelRenderable;
import com.google.ar.sceneform.rendering.ViewRenderable;
import com.squareup.picasso.Picasso;

/**
 * Node that represents a planet.
 *
 * <p>The planet creates two child nodes when it is activated:
 *
 * <ul>
 *   <li>The visual of the planet, rotates along it's own axis and renders the planet.
 *   <li>An info card, renders an Android View that displays the name of the planerendt. This can be
 *       toggled on and off.
 * </ul>
 *
 * The planet is rendered by a child instead of this node so that the spinning of the planet doesn't
 * make the info card spin as well.
 */
public class Planet extends Node {
  private final float planetScale;
  private final float orbitDegreesPerSecond;
  private final float axisTilt;
  private final ModelRenderable planetRenderable;
  private final SolarSettings solarSettings;

  private Node infoCard;
  private RotatingNode planetVisual;
  private final Context context;

  private final Blog blog;

  private static final float INFO_CARD_Y_POS_COEFF = 0.55f;

  public Planet(
      Context context,
      float planetScale,
      float orbitDegreesPerSecond,
      float axisTilt,
      ModelRenderable planetRenderable,
      SolarSettings solarSettings,
      Blog blog) {
    this.context = context;
    this.planetScale = planetScale;
    this.orbitDegreesPerSecond = orbitDegreesPerSecond;
    this.axisTilt = axisTilt;
    this.planetRenderable = planetRenderable;
    this.solarSettings = solarSettings;
    this.blog = blog;
  }

  @Override
  @SuppressWarnings({"AndroidApiChecker", "FutureReturnValueIgnored"})
  public void onActivate() {

    if (getScene() == null) {
      throw new IllegalStateException("Scene is null!");
    }

    if (infoCard == null) {
      infoCard = new Node();
      infoCard.setParent(this);
      infoCard.setLocalPosition(new Vector3(0.0f, planetScale * INFO_CARD_Y_POS_COEFF, 0.0f));

      ViewRenderable.builder()
          .setView(context, R.layout.ar_item_view)
          .build()
          .thenAccept(
              (renderable) -> {
                infoCard.setRenderable(renderable);
                ViewGroup viewGroup = (ViewGroup) renderable.getView();
                ImageView userAvatarView = viewGroup.findViewById(R.id.user_avatar);
                Picasso.get().load(blog.user.icon).into(userAvatarView);
                ((TextView) viewGroup.findViewById(R.id.user_name)).setText(blog.user.nickName);
                ((TextView) viewGroup.findViewById(R.id.blog_title)).setText(blog.title);
                ((TextView) viewGroup.findViewById(R.id.blog_content)).setText(blog.content);
              })
          .exceptionally(
              (throwable) -> {
                throw new AssertionError("Could not load plane card view.", throwable);
              });
    }

    if (planetVisual == null) {
      // Put a rotator to counter the effects of orbit, and allow the planet orientation to remain
      // of planets like Uranus (which has high tilt) to keep tilted towards the same direction
      // wherever it is in its orbit.
      RotatingNode counterOrbit = new RotatingNode(solarSettings, true, true, 0f);
      counterOrbit.setDegreesPerSecond(orbitDegreesPerSecond);
      counterOrbit.setParent(this);

      planetVisual = new RotatingNode(solarSettings, false, false, axisTilt);
      planetVisual.setParent(counterOrbit);
      planetVisual.setRenderable(planetRenderable);
      planetVisual.setLocalScale(new Vector3(planetScale, planetScale, planetScale));
    }
  }

  @Override
  public void onUpdate(FrameTime frameTime) {
    if (infoCard == null) {
      return;
    }

    // Typically, getScene() will never return null because onUpdate() is only called when the node
    // is in the scene.
    // However, if onUpdate is called explicitly or if the node is removed from the scene on a
    // different thread during onUpdate, then getScene may be null.
    if (getScene() == null) {
      return;
    }
    Vector3 cameraPosition = getScene().getCamera().getWorldPosition();
    Vector3 cardPosition = infoCard.getWorldPosition();
    Vector3 direction = Vector3.subtract(cameraPosition, cardPosition);
    Quaternion lookRotation = Quaternion.lookRotation(direction, Vector3.up());
    infoCard.setWorldRotation(lookRotation);
  }
}
