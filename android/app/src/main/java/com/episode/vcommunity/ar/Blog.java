package com.episode.vcommunity.ar;

import java.util.ArrayList;
import java.util.List;

public class Blog {

    String id = "0";
    int buildingId = 0;
    int userId = 0;
    User user;
    String topicId = "";
    String title;
    String images;
    String content;
    double longitude;
    double latitude;
    int liked = 0;
    int comments = 0;
    int views = 0;

    boolean deleted = false;
    boolean isLike = false;
    List<Topic> topics = new ArrayList<>();
    double distanceValue;
    String distanceMetric;

}
