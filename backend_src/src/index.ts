import { Router } from 'itty-router'

const router = Router()

// GET Code to Login to Bittify
router.get('/callback', (res) =>
	new Response(`Paste this into your Bittify Application: ${res.query["code"]}`)
)

// GET Access_token:
router.get('/get_access_token', async (res) => {
	const { query } = res

	const auth_header = btoa(`${Bittify_Client_ID}:${Bittify_Client_Secret}`)
	const data = new URLSearchParams()

	data.append("grant_type", "authorization_code")
	data.append("code", query["code"] as string)
	data.append("redirect_uri", query["redirect_url"] as string)

	const response = await fetch("https://accounts.spotify.com/api/token", {
		method: "POST",
		headers: {
			"Content-Type": "application/x-www-form-urlencoded",
			"Authorization": `Basic ${auth_header}`
		},	
		body: data.toString()
	});

	return response
})

// GET Refresh_Token:
router.get('/get_refresh_token', async (res) => {
	const { query } = res

	const auth_header = btoa(`${Bittify_Client_ID}:${Bittify_Client_Secret}`)

	const data = new URLSearchParams()

	data.append("grant_type", "refresh_token")
	data.append("refresh_token", query["refresh_token"] as string)

	const response = await fetch("https://accounts.spotify.com/api/token", {
		method: "POST",
		headers: {
			"Content-Type": "application/x-www-form-urlencoded",
			"Authorization": `Basic ${auth_header}`
		},
		body: data.toString()
	});
	
	return response
})

router.get('/ping', (res) =>
	new Response("Pong")
)

addEventListener('fetch', event =>
	event.respondWith(router.handle(event.request))
)