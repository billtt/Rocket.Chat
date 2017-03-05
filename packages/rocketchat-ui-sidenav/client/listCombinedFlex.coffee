Template.listCombinedFlex.helpers
	channel: ->
		return Template.instance().channelsList?.get()
	hasMore: ->
		return Template.instance().hasMore.get()
	sortChannelsSelected: (sort) ->
		return Template.instance().sortChannels.get() is sort
	sortSubscriptionsSelected: (sort) ->
		return Template.instance().sortSubscriptions.get() is sort
	showSelected: (show) ->
		return Template.instance().show.get() is show
	channelTypeSelected: (type) ->
		return Template.instance().channelType.get() is type
	member: ->
		return !!RocketChat.models.Subscriptions.findOne({ name: @name, open: true })
	hidden: ->
		return !!RocketChat.models.Subscriptions.findOne({ name: @name, open: false })
	roomIcon: ->
		return RocketChat.roomTypes.getIcon @t, @unjoinable
	url: ->
		return if @t is 'p' then 'group' else 'channel'

Template.listCombinedFlex.events
	'click header': ->
		SideNav.closeFlex()

	'click .channel-link': ->
		SideNav.closeFlex()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'scroll .content': _.throttle (e, t) ->
		if t.hasMore.get() and e.target.scrollTop >= e.target.scrollHeight - e.target.clientHeight
			t.limit.set(t.limit.get() + 50)
	, 200

	'submit .search-form': (e) ->
		e.preventDefault()

	'keyup #channel-search': _.debounce (e, instance) ->
		instance.nameFilter.set($(e.currentTarget).val())
	, 300

	'change #sort-channels': (e, instance) ->
		instance.sortChannels.set($(e.currentTarget).val())

	'change #channel-type': (e, instance) ->
		instance.channelType.set($(e.currentTarget).val())

	'change #sort-subscriptions': (e, instance) ->
		instance.sortSubscriptions.set($(e.currentTarget).val())

	'change #show': (e, instance) ->
		show = $(e.currentTarget).val()
		if show is 'joined'
			instance.$('#sort-channels').hide();
			instance.$('#sort-subscriptions').show();
		else
			instance.$('#sort-channels').show();
			instance.$('#sort-subscriptions').hide();
		instance.show.set(show)

Template.listCombinedFlex.onCreated ->
	@channelsList = new ReactiveVar []
	@hasMore = new ReactiveVar true
	@limit = new ReactiveVar 50
	@nameFilter = new ReactiveVar ''
	@sortChannels = new ReactiveVar 'name'
	@sortSubscriptions = new ReactiveVar 'name'
	@channelType = new ReactiveVar 'all'
	@show = new ReactiveVar 'all'
	@type = if @t is 'p' then 'group' else 'channel'

	@autorun =>
		limit = null
		if _.isNumber @limit.get()
			limit = @limit.get()
		sort = null
		if _.trim(@sortSubscriptions.get())
			sort = @sortSubscriptions.get()
		nameFilter = new RegExp s.trim(s.escapeRegExp(@nameFilter.get())), "i"
		joined = @show.get() is 'joined'
		type = {$in: ['c', 'p']}
		if _.trim(@channelType.get())
			switch @channelType.get()
				when 'public'
					type = 'c'
				when 'private'
					type = 'p'
		@channelsList.set RocketChat.roomUtil.getRoomList(joined, type, nameFilter, sort, limit)
		if @channelsList.get().length < @limit.get()
			@hasMore.set false
