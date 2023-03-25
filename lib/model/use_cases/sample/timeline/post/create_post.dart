import 'package:flutter_app_template/model/use_cases/sample/timeline/fetch_timeline.dart';
import 'package:flutter_app_template/model/use_cases/sample/timeline/fetch_timeline_post_count.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../entities/sample/developer.dart';
import '../../../../entities/sample/timeline/post.dart';
import '../../../../repositories/firebase_auth/firebase_auth_repository.dart';
import '../../../../repositories/firestore/document.dart';
import '../../../../repositories/firestore/document_repository.dart';

final createPostProvider = Provider(CreatePost.new);

class CreatePost {
  CreatePost(this._ref);
  final Ref _ref;

  Future<void> call({
    required String text,
  }) async {
    /// 自身のユーザIDを取得
    final userId = _ref.read(firebaseAuthRepositoryProvider).loggedInUserId;
    if (userId == null) {
      return;
    }

    /// 保存する投稿データを設定
    final postId = Document.docId(Post.collectionName);
    final now = DateTime.now();
    final post = Post(
      postId: postId,
      userId: userId,
      text: text,
      createdAt: now, // オブザーバー用に設定
      updatedAt: now, // オブザーバー用に設定
    );

    /// サーバーへ保存する
    await _ref.read(documentRepositoryProvider).save(
          Developer.postDocPath(
            userId: userId,
            docId: postId,
          ),
          data: post.toCreateDoc,
        );

    /// 作成したことを反映
    _ref
      ..invalidate(fetchTimelineAsyncProvider)
      ..invalidate(fetchTimelinePostCountFutureProvider);
  }
}
