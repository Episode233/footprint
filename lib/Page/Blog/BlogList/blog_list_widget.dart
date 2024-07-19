import 'package:flutter/material.dart';
import 'package:vcommunity_flutter/Model/blog.dart';
import 'package:vcommunity_flutter/Page/Blog/BlogList/components/blog_list_item.dart';

class BlogListWidget extends StatefulWidget {
  List<Blog> blogs;
  BlogListWidget(this.blogs, {super.key});

  @override
  State<BlogListWidget> createState() => _BlogListWidgetState();
}

class _BlogListWidgetState extends State<BlogListWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: ((context, index) {
        return BlogListItem(widget.blogs[index]);
      }),
      itemCount: widget.blogs.length,
    );
  }
}
