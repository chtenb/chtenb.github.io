module Main where

import Prelude

import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web as Affjax
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Milliseconds(..), delay)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect)
import Effect.Console as Console
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import HalogenUtils (classString, fontAwesome, optionalText)
import Html.Renderer.Halogen as RH
import LocationString (getFragmentString, getQueryParam, setHash)
import Web.HTML.HTMLElement as HTMLElement

foreign import executeJavascriptHacks :: Effect Unit
foreign import executeSiteAnalytics :: Effect Unit
foreign import spy :: forall a. a -> Effect Unit

data Action = Initialize

type State =
  { loading :: Boolean
  , page :: String -- Identifier of the page
  , pageHtml :: Maybe String -- Html of the page
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
initialState _ = { loading: false, page: "toc", pageHtml: Nothing }

refContent :: H.RefLabel
refContent = H.RefLabel "page-content"

render :: forall m. State -> H.ComponentHTML Action () m
render state = HH.div
  [ classString "main" ]
  [ renderHeader
  , renderContent
  ]
  where
  renderContent = HH.div
    [ classString "pageContent" ]
    case state.pageHtml of
      Just html -> [ HH.div [ HP.ref refContent ] [ RH.render_ html ] ]
      Nothing -> []
  renderHeader = HH.div
    [ classString "pageHeader" ]
    [ renderTitle
    , renderControls
    , renderLoadingIcon
    ]
  renderTitle = HH.div
    [ classString "pageTitle" ]
    [ HH.a
        [ HP.href "/"
        , HP.target "_parent"
        ]
        [ HH.h1_ [ HH.text "devblog" ] ]
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
            [ fontAwesome "fa-code", optionalText " website code" ]
        ]
    , HH.a
        [ HP.href "https://github.com/chtenb/chtenb.github.io/discussions"
        , HP.target "_blank"
        , HP.tabIndex (-1)
        ]
        [ HH.button
            [ HP.title "Open the discussion page in a new browser tab" ]
            [ fontAwesome "fa-comments", optionalText " discussions" ]
        ]
    ]

handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction action =
  case action of
    Initialize -> do
      maybePage <- H.liftEffect $ getQueryParam "page"
      case maybePage of
        Nothing -> pure unit
        Just page -> do
          H.modify_ _ { page = page }

      loadPageHtml
      H.liftEffect executeSiteAnalytics
      focusContent
      H.liftAff $ delay $ Milliseconds 100.0 -- It takes a while before the embedded html is fully loaded
      H.liftEffect scrollToAnchor

loadPageHtml :: forall output m. MonadAff m => H.HalogenM State Action () output m Unit
loadPageHtml = do
  state <- H.get
  let url = getPageUrl state.page
  eitherResponse <- H.liftAff $ Affjax.get (ResponseFormat.String identity) url
  case eitherResponse of
    Right response -> do
      H.modify_ _ { pageHtml = Just response.body }
    Left error -> H.liftEffect $ Console.error ("Could not retrieve html for " <> url <> ": " <> Affjax.printError error)

focusContent :: forall output m. MonadEffect m => H.HalogenM State Action () output m Unit
focusContent = do
  maybeContentElem <- H.getHTMLElementRef refContent
  case maybeContentElem of
    Nothing -> H.liftEffect $ Console.error "Could not find content"
    Just contentElem -> H.liftEffect $ HTMLElement.focus contentElem

scrollToAnchor :: Effect Unit
scrollToAnchor = do
  hash <- getFragmentString
  setHash ""
  setHash hash

