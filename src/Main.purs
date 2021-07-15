module Main where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect)
import Effect.Console as Console
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import HalogenUtils (classString, fontAwesome, optionalText)
import LocationString (getQueryParam, setQueryString)
import Web.HTML as WH
import Web.HTML.HTMLDocument as HTMLDocument
import Web.HTML.HTMLElement as HTMLElement
import Web.HTML.HTMLIFrameElement as HTMLIFrameElement
import Web.HTML.Window (document)

foreign import executeJavascriptHacks :: Effect Unit

data Action = Initialize | PostLoad

type State =
  { loading :: Boolean
  , page :: String
  }

getPageUrl :: String -> String
getPageUrl page = "/blog/" <> page <> ".html"

main :: Effect Unit
main = do
  executeJavascriptHacks
  HA.runHalogenAff do
    body <- HA.awaitBody
    runUI component unit body


component :: forall query input output m. MonadAff m => H.Component query input output m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval 
      { handleAction = handleAction 
      , initialize = Just Initialize
      }
    }

initialState :: forall input. input -> State
initialState _ = { loading: false, page: "unit-cs" }

refContent :: H.RefLabel
refContent = H.RefLabel "content-iframe"

render :: forall m. State -> H.ComponentHTML Action () m
render state = HH.div
  [ classString "main" ]
  [ renderHeader
  , renderContent
  ]
  where
  renderContent = HH.div
    [ classString "content" ]
    [ HH.iframe [ HP.src $ getPageUrl state.page, HP.ref refContent, HE.onLoad (\_ -> PostLoad) ] ]
  renderHeader = HH.div
    [ classString "header" ]
    [ renderTitle
    , renderControls
    , renderLoadingIcon
    ]
  renderTitle = HH.div
    [ classString "title largeViewport"]
    [ HH.a
      [ HP.href "https://github.com/chtenb/chtenb.github.io"
      , HP.target "_blank"
      ]
      [ HH.h1_ [ HH.text "Devblog" ] ]
    ]
  renderLoadingIcon = HH.div 
    [ classString "loadingIcon lds-ellipsis" ]
    if state.loading then [ HH.div_ [], HH.div_ [], HH.div_ [], HH.div_ [] ] else []
  renderControls = HH.div 
    [ classString "controls" ]
    [ HH.a
      [ HP.href "https://github.com/chtenb/chtenb.github.io"
      , HP.target "_blank"
      , HP.tabIndex (-1)
      ]
      [ HH.button
        [ HP.title "Open the source code of this website in a new browser tab" ]
        [ fontAwesome "fa-code", optionalText " Website Code" ] ]
    , HH.a
      [ HP.href "https://github.com/chtenb/chtenb.github.io/discussions"
      , HP.target "_blank"
      , HP.tabIndex (-1)
      ]
      [ HH.button
        [ HP.title "Open the discussion page in a new browser tab" ]
        [ fontAwesome "fa-comments", optionalText " Discussions" ] ]
    ]

handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction action =
  case action of
    Initialize -> do
      focusContent
      maybePage <- H.liftEffect $ getQueryParam "page"
      case maybePage of
        Nothing -> do
          state <- H.get
          H.liftEffect $ setQueryString $ "page=" <> state.page
        Just page -> H.modify_ _ { page = page }
    PostLoad -> syncDocumentTitle

focusContent :: forall output m . MonadEffect m => H.HalogenM State Action () output m Unit
focusContent = do
  maybeContentElem <- H.getHTMLElementRef refContent
  case maybeContentElem of
    Nothing -> H.liftEffect $ Console.error "Could not find content"
    Just contentElem -> H.liftEffect $ HTMLElement.focus contentElem


setDocumentTitle :: String -> Effect Unit
setDocumentTitle title = do
    window <- WH.window
    document <- document window
    HTMLDocument.setTitle title document

getContentIFrame :: forall output m. MonadEffect m => H.HalogenM State Action () output m (Maybe WH.HTMLIFrameElement)
getContentIFrame = do
  maybeHtmlElement <- H.getHTMLElementRef refContent
  pure $ maybeHtmlElement >>= HTMLIFrameElement.fromHTMLElement

getContentDocument :: forall output m. MonadEffect m => H.HalogenM State Action () output m (Maybe WH.HTMLDocument)
getContentDocument = do
  maybeIFrameElement <- getContentIFrame
  case maybeIFrameElement of
    Nothing -> pure Nothing
    Just iframe -> H.liftEffect $ do
      maybeDocument <- HTMLIFrameElement.contentDocument iframe
      pure $ maybeDocument >>= HTMLDocument.fromDocument

getContentTitle :: forall output m. MonadEffect m => H.HalogenM State Action () output m (Maybe String)
getContentTitle = do
  maybeContentDocument <- getContentDocument
  case maybeContentDocument of
    Nothing -> pure Nothing
    Just doc -> H.liftEffect $ do
      title <- HTMLDocument.title doc
      pure $ Just title

syncDocumentTitle :: forall output m. MonadEffect m => H.HalogenM State Action () output m Unit
syncDocumentTitle = do
  title <- getContentTitle
  H.liftEffect $ case title of
    Nothing -> Console.error("Could not retrieve iframe document title")
    Just s -> setDocumentTitle s
