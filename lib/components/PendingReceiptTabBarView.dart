import 'package:flutter/material.dart';
import 'package:grocery_shop_flutter/bloc/ReceiptBloc.dart';
import 'package:grocery_shop_flutter/bloc/UserBloc.dart';
import 'package:grocery_shop_flutter/components/MyOrderWidget.dart';
import 'package:grocery_shop_flutter/models/Receipt.dart';
import 'package:intl/intl.dart';

class PendingReceiptTabBarView extends StatefulWidget {
  @override
  _PendingReceiptTabBarViewState createState() =>
      _PendingReceiptTabBarViewState();
}

class _PendingReceiptTabBarViewState extends State<PendingReceiptTabBarView>
    with AutomaticKeepAliveClientMixin<PendingReceiptTabBarView> {
  final _userBloc = UserBloc();
  final _receiptBloc = ReceiptBloc();
  bool isLoading = true;
  List<Receipt> _lstSortPendingReceipts = [];

  sortByDate(List<Receipt> receipts) {
    List<Receipt> sortReceipts = [];
    receipts.sort((a, b) => b.billDate.compareTo(a.billDate));
    for (var r in receipts) {
      sortReceipts.add(r);
    }
    return sortReceipts;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _receiptBloc.getReceiptPending(_userBloc.userInfo.userID).then((bool a) {
      setState(() {
        isLoading = false;
      });
    });
    // TODO: implement initState
    super.initState();
    print('DetailCommentHeaderState initState');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("DetailCommentListHeader dispose");
  }

  getDate(DateTime dateTimeInput) {
    String processedDate;
    processedDate = DateFormat('dd/MM/yyyy - H:m:s').format(dateTimeInput);
    return processedDate;
  }

  Future<Null> refeshList() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _receiptBloc.getReceiptPending(_userBloc.userInfo.userID).then((bool a) {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: _receiptBloc.pendingReceipts,
        stream: _receiptBloc.observableReceiptPending,
        builder: (context, snapshot) {
          if ((snapshot.data == null || snapshot.data.length == 0) &&
              !isLoading) {
            return Container(
              child: Center(
                child: Text("Hiện không có đơn hàng nào!"),
              ),
            );
          } else {
            List<Receipt> _receipts = snapshot.data;
            _lstSortPendingReceipts=sortByDate(_receipts);
            return RefreshIndicator(
              child: ListView.builder(
                  itemCount: _receipts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        decoration: new BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 13.0,
                              color: Colors.black.withOpacity(.5),
                              offset: Offset(6.0, 7.0),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(color: Colors.grey, width: 2.0),
                          gradient: new LinearGradient(
                              colors: [Colors.amber, Colors.white],
                              begin: Alignment.centerRight,
                              end: new Alignment(-1.0, -1.0)),
                        ),
                        child: Center(
                          child: MyOrderWidget(
                            isPending: true,
                            receipt: _receipts[index],
                          ),
                        ),
                      ),
                    );
                  }),
              onRefresh: refeshList,
            );
          }
        });
  }
}
