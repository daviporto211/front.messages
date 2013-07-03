root = exports ? window
window.vtex or = {}

###*
# Classe Message, que representa uma mensagem
# @class Message
# @constructor
###
class Message
	constructor: (options = {}) ->
		classes =			
			TEMPLATEDEFAULT: '.vtex-message-template.vtex-message-template-default'
			MODALTEMPLATEDEFAULT: '.vtex-message-template.vtex-message-template-modal-default'
			PLACEHOLDER: '.vtex-message-placeholder'
			MODALPLACEHOLDER: 'body'
			TEMPLATE: 'vtex-message-template'
			TITLE: '.vtex-message-title'
			DETAIL: '.vtex-message-detail'
			TYPE: 'vtex-message-type-'

		defaultProperties =
			id: _.uniqueId('vtex-message-')
			placeholder: classes.PLACEHOLDER
			modalPlaceholder: classes.MODALPLACEHOLDER
			template: classes.TEMPLATE
			modalTemplate: classes.MODALTEMPLATE
			content:
				title: ''
				detail: ''
			type: 'info'
			visible: false
			usingModal: false
			domElement: $()
			insertMethod: 'append'
		_.extend(@, defaultProperties, options)

		modalDefaultTemplate = """
		<div class="vtex-message-template vtex-message-template-modal-default modal hide fade">
			<div class="modal-header">
				<h3 class="vtex-message-title"></h3>
			</div>
			<div class="modal-body">
				<p class="vtex-message-detail"></p>
			</div>
		</div>
		"""

		defaultTemplate = """
		<div class="vtex-message-template vtex-message-template-default">
			<h1 class="vtex-message-title"></h1>
			<p class="vtex-message-detail"></p>
		</div>
		"""

		if @type is 'fatal' then @usingModal = true

		if @usingModal
			if not $(@modalPlaceholder)[0] then throw new Error("Couldn't find placeholder for modal Message")
			
			if @modalTemplate is classes.MODALTEMPLATE
				@modalTemplate = modalDefaultTemplate
			else
				if not $(@modalTemplate)[0] then throw new Error("Couldn't find specified template for modal Message")

			@domElement = $(@modalTemplate)
		else
			if not $(@placeholder)[0] then throw new Error("Couldn't find placeholder for Message")

			if @template is classes.TEMPLATE
				@template = defaultTemplate
			else
				if not $(@template)[0] then throw new Error("Couldn't find specified template for Message")

			@domElement = $(@template).clone(false, false)

		$(@domElement).removeClass(classes.TEMPLATE)
		$(@domElement).addClass(classes.TYPE+@type+" "+@id)
		$(@domElement).hide()
		$(@domElement).data('vtex-message', @)
		$(classes.TITLE, @domElement).html(@content.title)
		$(classes.DETAIL, @domElement).html(@content.detail)

		if @usingModal
			$(@domElement).on 'hidden', => @visible = false
			$(@modalPlaceholder).append(@domElement)
		else
			$(@placeholder)[@insertMethod](@domElement)

		if @visible then @show()

		return

	###*
	# Exibe a mensagem da tela
	# @method show
	# @param {Object|Number} fadeInObj caso preenchido, será passado como parametro para o método 
	#[fadeIn do jQuery](http://api.jquery.com/fadeIn/)
	# @return 
	###
	show: (fadeInObj) =>
		if @usingModal
			visibleModal = $('.modal:visible')
			if visibleModal.length > 0 and visibleModal[0] isnt @domElement[0]
				visibleModal.one 'hidden', =>
					$(@domElement).modal('show')
					@visible = true
			else
				$(@domElement).modal('show')
				@visible = true
			return

		if typeof fadeInObj is 'object' or typeof fadeInObj is 'number'
			if typeof fadeInObj is 'object' and fadeInObj.complete? and typeof fadeInObj.complete is 'function'
				userDone = fadeInObj.complete
				fadeInObj.complete = =>
					@visible = true
					userDone()
				@domElement.fadeIn(fadeInObj)
			else if typeof fadeInObj is 'number'
				@domElement.fadeIn(fadeInObj, => @visible = true)
		else
			@domElement.show()
			@visible = true

	###*
	# Esconde a mensagem da tela
	# @method hide
	# @param {Object|Number} fadeOutObj caso preenchido, será passado como parametro para o método 
	#[fadeOut do jQuery](http://api.jquery.com/fadeOut/)
	# @return 
	###
	hide: (fadeOutObj) =>
		if @usingModal
			@domElement.modal('hide')
			@visible = false
			return

		if fadeOutObj
			if typeof fadeOutObj is 'object' and fadeOutObj.complete? and typeof fadeOutObj.complete is 'function'
				userDone = fadeOutObj.complete
				fadeOutObj.complete = =>
					@visible = false
					userDone()
				@domElement.fadeOut(fadeOutObj)
			else if typeof fadeOutObj is 'number'
				@domElement.fadeOut(fadeOutObj, => @visible = false)
		else
			@domElement.hide()
			@visible = false
###*
# Classe Messages, que agrupa todas as mensagens
# @class Messages
# @constructor
###
class Messages
	###
	# Construtor
	# @param {Object} options propriedades a ser extendida pelo plugin
	# @return {Object} Messages
	###
	constructor: (options = {}) ->
		defaultProperties = 
			ajaxError: false
			messagesArray: []
		_.extend(@, defaultProperties, options)

		@bindAjaxError() if @ajaxError

	###*
	# Adiciona uma mensagem ao objeto Messages, exibe na tela imediatamente caso passado param show como true
	# @method addMessage
	# @param {Object} message
	# @param {Boolean} show caso verdadeiro, após a criação da mensagem, ela será exibida 
	# @return {Object} retorna a instancia da Message criada
	###
	addMessage: (message, show = false) =>
		messageObj = new Message(message)
		@messagesArray.push messageObj
		messageObj.show(show) if show
		return messageObj

	###*
	# Remove uma mensagem
	# @method removeMessage
	# @param {Object} messageProperty objeto Message ou objeto com alguma propriedade da mensagem a ser removida
	# @return
	###
	removeMessage: (messageProperty) =>
		results = _.where(@messagesArray, messageProperty)
		for message, i in @messagesArray
			for res in results
				if message.id is res.id
					@messagesArray.splice(i,1)
					return

	###*
	# Bind erros de Ajax para exibir modal de erro
	# @method bindAjaxError
	# @return
	###
	bindAjaxError: ->
		$(document).ajaxError (event, xhr, ajaxOptions, thrownError) =>
			return if xhr.status is 401 or xhr.status is 403
			# If refresh in the middle of an AJAX
			if xhr.readyState is 0 or xhr.status is 0 then return
			
			if window.i18n
				globalUnknownError = window.i18n.t('global.unkownError')
				globalError = window.i18n.t('global.error')
			else
				globalUnknownError = "An unexpected error ocurred."
				globalError = "Error"

			if xhr.getResponseHeader('x-vtex-operation-id')
				globalError += ' <small>(Operation ID ' 
				globalError += decodeURIComponent(xhr.getResponseHeader('x-vtex-operation-id')) 
				globalError += ')</small>'

			if xhr.getResponseHeader('x-vtex-error-message')
				errorMessage = JSON.parse(xhr.responseText).error.message 
			else 
				errorMessage = globalUnknownError

			# Exibe mensagem na tela
			messageObj =
				type: 'fatal'
				content:
					title: globalError	
					detail: errorMessage

			if getCookie("ShowFullError") is "Value=1"
				iframe = document.createElement('iframe')
				iframe.src = 'data:text/html;charset=utf-8,' + encodeURI(xhr.responseText)
				$(iframe).css('width', '100%')
				$(iframe).css('height', '900px')
				messageObj.content.detail = iframe

			@addMessage(messageObj, true)

	###*
	# Get cookie
	# @private
	# @method getCookie
	# @param {String} name nome do cookie
	# @return {String} valor do cookie
	###
	getCookie = (name) ->
		cookieValue = null
		if document.cookie and document.cookie isnt ""
			cookies = document.cookie.split(";")
			i = 0

			while i < cookies.length
				cookie = (cookies[i] or "").replace(/^\s+|\s+$/g, "")
				if cookie.substring(0, name.length + 1) is (name + "=")
					cookieValue = decodeURIComponent(cookie.substring(name.length + 1))
					break
				i++
		cookieValue
		
# exports
root.vtex.Messages = Messages
