import 'datamodel.dart';

class DataManager {
  List<ReceipeType>? _receipes;

  static const List<Map<String, dynamic>> _staticData = [
    {
      "name": "starter",
      "steps": [
        {
          "id": 1,
          "step": "1",
          "description":
              "Mix 20g of flour and 20g of water at room temperature in a glass jar. Cover with a lid, do not close too tightly and leave for a day at room temperature."
        },
        {
          "id": 2,
          "step": "2",
          "description":
              "Add 20g of flour and 20g of water to the starter and leave for one more day."
        },
        {
          "id": 3,
          "step": "3",
          "description":
              "Check the starter, if it doesn't 'move' and no pores have formed in it, add 20g of flour and 20g of water to it again."
        },
        {
          "id": 4,
          "step": "4",
          "description":
              "The starter should begin to smell. The smell can be different: it can smell of sauerkraut, pickles, kefir and even chemicals! Add 40g of flour and 40g of water and leave for another 12 hours. The sourdough starter by now should rise and be approximately double the size. If not, however, no worries, it will grow later. Take 40g of the starter and add 40g of water and 40g of flour to it. Leave for another 12 hours."
        },
        {
          "id": 5,
          "step": "5",
          "description":
              "Take 40g of the starter and add 40g of water and 40g of flour. Leave it for another 12 hours. The starter will become very 'active'. At night, 'feed' it again: add 40g of water and 40g of flour to this 40g starter."
        },
        {
          "id": 6,
          "step": "6 - 7",
          "description":
              "Time to check if the starter is ready. To test, take 15g of the starter and add 75g of flour and 75g of water. If it works well, it will double within 4-8 hours. However, home temperature plays a big role, if it's too fresh, the process will be slower. If you knead the dough for bread, and in 4-8 hours it has increased by 2-3 times, it means that the starter is already ready for baking."
        },
        {
          "id": 7,
          "step": "8 - 14",
          "description":
              "If the starter does not work, continue to 'feed' it with 40g of water and 40g of flour."
        },
        {
          "id": 8,
          "step": "What's next?",
          "description":
              "Sourdough starter can be stored in the refrigerator. If it has 'fallen', it means that it has become acidic, and before it can be used, it will need to be 'fed' again. 'Feeding' is always done by mixing 40g of starter, 40g of flour and 40g of water."
        }
      ]
    },
    {
      "name": "bread",
      "steps": [
        {
          "id": 1,
          "step": "1",
          "description":
              "'Feed' the starter the day before and leave it warm. Use boiled and lukewarm water. You can add the honey."
        },
        {
          "id": 2,
          "step": "2",
          "description": "Mix all ingredients and work on the dough well."
        },
        {
          "id": 3,
          "step": "3",
          "description":
              "Leave under a towel in a bowl for 2 hours. After that, slightly pull out the edge of the dough on one side and fold it inwards by a third."
        },
        {
          "id": 4,
          "step": "4",
          "description":
              "After an hour, repeat the same thing on the other side."
        },
        {
          "id": 5,
          "step": "5",
          "description":
              "Leave it for another hour, take it out again and fold it, and finally, after another 60 minutes, repeat the same operation for the fourth time."
        },
        {
          "id": 6,
          "step": "6",
          "description": "After that, leave the dough for 30 minutes."
        },
        {
          "id": 7,
          "step": "7",
          "description":
              "Sprinkle the bread form with flour. Form a loaf, put the bread in a mould and let it rise."
        },
        {
          "id": 8,
          "step": "8",
          "description":
              "Put the bread in the refrigerator overnight. Remove from the cold one hour before baking."
        },
        {
          "id": 9,
          "step": "9",
          "description":
              "Heat the oven to 240 degrees. Put the bread in a hot form on parchment, make a cut on top, cover with a lid. Bake for 20 minutes at 240 degrees celsius."
        }
      ]
    }
  ];

  fetchReceipes() {
    _receipes = [];
    for (var json in _staticData) {
      _receipes?.add(ReceipeType.fromJson(json));
    }
  }

  Future<List<ReceipeType>> getReceipes() async {
    if (_receipes == null) {
      fetchReceipes();
    }
    return _receipes!;
  }
}
