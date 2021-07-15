module Main where

import HalogenUtils
import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (class MonadEffect)
import Effect.Console as Console
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import Halogen.VDom.Driver (runUI)
import LocationString (getQueryParam, setQueryString)
import Web.HTML.HTMLElement (focus, toElement)

foreign import executeJavascriptHacks :: Effect Unit

data Action = Initialize

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
initialState _ = { loading: false, page: "rop-cs" }

refContent :: H.RefLabel
refContent = H.RefLabel "content"

render :: forall m. State -> H.ComponentHTML Action () m
render state = HH.div
  [ classString "main" ]
  [ renderHeader
  , renderContent
  ]
  where
  renderContent = HH.div
    [ classString "content" ]
    [ HH.iframe [ HP.src $ getPageUrl state.page, HP.ref refContent ] ]
  renderHeader = HH.div
    [ classString "header" ]
    [ renderTitle
    , renderControls
    , renderLoadingIcon
    ]
  renderTitle = HH.div
    [ classString "title largeViewport"]
    [ HH.a
      [ HP.href ""
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
      [ HP.href ""
      , HP.target "_blank"
      , HP.tabIndex (-1)
      ]
      [ HH.button [ HP.title "Open the about page in a new browser tab" ] [ fontAwesome "fa-info", optionalText " About" ] ]
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

focusContent :: forall output m . MonadEffect m => H.HalogenM State Action () output m Unit
focusContent = do
  maybeContentElem <- H.getHTMLElementRef refContent
  case maybeContentElem of
    Nothing -> H.liftEffect $ Console.error "Could not find content"
    Just contentElem -> H.liftEffect $ focus contentElem
