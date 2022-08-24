import 'dart:convert';

class SelectCategoryModel {
  GetSelectCategoryPage? getSelectCategoryPage;

  SelectCategoryModel({this.getSelectCategoryPage});

  SelectCategoryModel.fromJson(Map<String, dynamic> json) {
    getSelectCategoryPage = json['getSelectCategoryPage'] != null
        ? GetSelectCategoryPage.fromJson(json['getSelectCategoryPage'])
        : null;
  }
}

class GetSelectCategoryPage {
  List<SelectCategoryContent>? content;
  String? contentType;
  int? id;
  String? title;

  GetSelectCategoryPage({this.content, this.contentType, this.id, this.title});

  GetSelectCategoryPage.fromJson(Map<String, dynamic> json) {
    if (json['content'] != null) {
      content = <SelectCategoryContent>[];
      jsonDecode(json['content']).forEach((v) {
        content!.add(SelectCategoryContent.fromJson(v));
      });
    }
    contentType = json['content_type'];
    id = json['id'];
    title = json['title'];
  }
}

class SelectCategoryContent {
  String? blockTitle;
  int? blockId;
  List<SelectCategorySubContent>? selectCategorySubContent;

  SelectCategoryContent(
      {this.blockTitle, this.blockId, this.selectCategorySubContent});

  SelectCategoryContent.fromJson(Map<String, dynamic> json) {
    blockId = json['block_id'];
    blockTitle = json['block_title'];
    if (json['content'] != null) {
      selectCategorySubContent = <SelectCategorySubContent>[];
      json['content'].forEach((v) {
        selectCategorySubContent!.add(SelectCategorySubContent.fromJson(v));
      });
    }
  }
}

class SelectCategorySubContent {
  String? imageUrl;
  String? linkType;
  String? linkId;

  SelectCategorySubContent({this.imageUrl, this.linkId, this.linkType});
  SelectCategorySubContent.fromJson(Map<String, dynamic> json) {
    imageUrl = json['image_url'];
    linkType = json['link_type'];
    linkId = json['link_id'];
  }
}
