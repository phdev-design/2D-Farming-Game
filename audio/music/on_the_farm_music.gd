extends AudioStreamPlayer2D

func _ready():
	# 檢查節點上是否有掛載音訊流 (stream)
	if stream:
		# 將音訊流的循環模式設定為向前循環 (LOOP_FORWARD)
		# 這等同於在屬性面板中選擇 "Forward"
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
