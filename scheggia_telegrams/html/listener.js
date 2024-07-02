window.addEventListener('message', (event) => {
	var telegram = event.data

	if (telegram.message == null) {
		$("body").hide();
	} else if (telegram.message == "Nessun telegramma in arrivo.") {
		$("body").show();
		$('.telegram_message').html(telegram.message);
	} else {
		$("body").show();
		$('.telegram_sender').html(telegram.sender);
		$('.telegram_message').html(telegram.message);
	}

	$(".telegram_back_button").unbind().click(function(){
		$.post('http://scheggia_telegrams:/back', JSON.stringify({})
	  );
	});

	$(".telegram_next_button").unbind().click(function(){
		$.post('http://scheggia_telegrams:/next', JSON.stringify({})
	  );
	});

	$(".telegram_new_button").unbind().click(function(){
		$.post('http://scheggia_telegrams:/new', JSON.stringify({})
	  );
	});

	$(".telegram_close_button").unbind().click(function(){
		$.post('http://scheggia_telegrams:/close', JSON.stringify({})
	  );
	});
	
	$(".telegram_delete_button").unbind().click(function(){
		$.post('http://scheggia_telegrams:/delete', JSON.stringify({})
	  );
	});
});