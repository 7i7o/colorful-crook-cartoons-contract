// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvgStart = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { font-family: helvetica; font-size: 36px; paint-order: stroke; stroke: white; stroke-width: 1px; }</style><defs><linearGradient id='grad1' x1='0' y1='0' x2='100%' y2='100%'><stop stop-color='";
    string baseSvgBetweenColors = "'/><stop offset='1' stop-color='";
    string baseSvgBetweenGradients = "'/></linearGradient><linearGradient id='grad2' x1='0' y1='0' x2='100%' y2='100%'><stop stop-color='";
    string baseSvgBeforeText1 = "'/></linearGradient></defs><rect width='100%' height='100%' fill='url(#grad1)' /><text x='50%' y='35%' fill='url(#grad2)' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string baseSvgBeforeText2 = "</text><text x='50%' y='50%' fill='url(#grad2)' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string baseSvgBeforeText3 = "</text><text x='50%' y='65%' fill='url(#grad2)' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string baseSvgEnd = "</text></svg>";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever! 
    string[] firstWords = ["Accidentally", "Actually", "Always", "Annually", "Anxiously", "Arrogantly",
                        "Awkwardly", "Beautifully", "Bitterly", "Bravely", "Briefly", "Carefully",
                        "Certainly", "Daily", "Doubtfully", "Easily", "Elegantly", "Especially", "Exactly", "Fairly",
                        "Generally", "Greatly", "Happily", "Helpfully", "Honestly", "Immediately", "Innocently",
                        "Jealously", "Keenly", "Lively", "Miserably", "Mysteriously", "Naturally",
                        "Officially", "Often", "Politely", "Quickly", "Randomly", "Rapidly", "Regularly",
                        "Seldom", "Slowly", "Suddenly", "Thankfully", "Unexpectedly", "Unfortunately",
                        "Usefully", "Voluntarily", "Wrongly", "Zealously"];
      string[] secondWords = ["Zonked", "Looped", "Potted", "High", "Spaced-out", "Intoxicated", "Malicious", "Mad",
                        "Lit", "Loaded", "Tripping", "Pickled", "Sloshed", "Cockeyed", "Stewed", "Cruel", "Malign",
                        "Hopped-up", "RippedOut", "Inebriated", "Plastered", "Blind", "Unkind", "Bitter", "Savage",
                        "Sodden", "Pixilated", "Smashed", "Doped", "Boozed", "Unconscious", "Drugged", "Mean",
                        "Boozy", "Crapulent", "Soused", "Besotted", "Bombed", "Crocked", "Drunk", "Resentful", "Angry",
                        "Drunken", "Tipsy", "Stinking", "Tight", "WipedOut", "Stinko", "Crapulous", "Nasty" ];
    string[] thirdWords = ["Mickey", "Minnie", "Donald", "Daisy", "Goofy", "Snow White", "Pinocchio",
                        "Dumbo", "Cinderella", "Alice", "Peter Pan", "Sleeping Beauty", 
                        "Pooh", "Ariel", "Beast", "Belle", "Aladdin",
                        "Jasmine", "Simba", "Woody", "Buzz", "Quasimodo", "Esmeralda", "Hercules",
                        "Mulan", "Tarzan", "Sullivan", "Wazowski", "Lilo", "Stitch", "Nemo", "Dory",
                        "Wall-e", "Eve", "Rapunzel", "Merida", "Ralph", "Vanellope", "Elsa", "Anna", "Olaf",
                        "Baymax", "Joy", "Sadness", "Fear", "Anger", "Disgust", "Moana", "Maui", "Coco" ];

    uint256 NFT_MAX_LIMIT = firstWords.length;
    // Here we define the Event to be emitted when a new NFT is minted!
    event NewEpicNFTMinted(address sender, uint256 tokenId, uint256 mintedSoFar);
  constructor() ERC721 ("Colorful Crook Cartoons", "CCC") {
    console.log("This is my NFT contract. Woah!");
  }

  // Function to randomly select a word from an array and remove it
  function pickRandomWord(uint256 tokenId, string memory seed, string[] storage words) private returns (string memory) {
      uint256 rand = random(string(abi.encodePacked(seed, Strings.toString(tokenId))));
      rand = rand % words.length;
      string memory word = words[rand];
      words[rand] = words[words.length - 1];
      words.pop();
      return word;
  }

  // Returns a random color and its complementary as a string in the format 'rgb(255,255,255)'
  function pickRandomColors(uint256 tokenId) internal pure returns (string memory, string memory) {
    uint8 r = uint8(random(string(abi.encodePacked("RED", Strings.toString(tokenId)))) % 256);
    uint8 g = uint8(random(string(abi.encodePacked("GREEN", Strings.toString(tokenId)))) % 256);
    uint8 b = uint8(random(string(abi.encodePacked("BLUE", Strings.toString(tokenId)))) % 256);
    string memory color = string(abi.encodePacked("rgb(", Strings.toString(r), ",", Strings.toString(g), ",", Strings.toString(b), ")"));
    string memory complColor = string(abi.encodePacked("rgb(", Strings.toString(255-r), ",", Strings.toString(255-g), ",", Strings.toString(255-b), ")"));
    return (color, complColor);
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

  function getTotalNFTsMintedSoFar() public view returns (uint256) {
      return NFT_MAX_LIMIT - firstWords.length;
  }

  function getMaxNFTCount() public view returns (uint256) {
      return NFT_MAX_LIMIT;
  }

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();
    require(firstWords.length > 0, "Sorry! Complete NFT Collection has already been minted.");
    uint256 seedNumber = block.timestamp + newItemId;
    // We go and randomly grab one word from each of the three arrays.
    string memory first = pickRandomWord(seedNumber, "FIRST_WORD", firstWords);
    string memory second = pickRandomWord(seedNumber, "SECOND_WORD", secondWords);
    string memory third = pickRandomWord(seedNumber, "THIRD_WORD", thirdWords);
    string memory combinedWord = string(abi.encodePacked(first, " ", second, " ", third));

    string memory color;
    string memory complColor;
    (color, complColor) = pickRandomColors(seedNumber);

    // I concatenate it all together, and then close the <text> and <svg> tags.
    string memory finalSvg = string(abi.encodePacked(baseSvgStart, color, baseSvgBetweenColors, complColor)); 
    finalSvg = string(abi.encodePacked(finalSvg, baseSvgBetweenGradients, complColor, baseSvgBetweenColors));
    finalSvg = string(abi.encodePacked(finalSvg, color, baseSvgBeforeText1, first));
    finalSvg = string(abi.encodePacked(finalSvg, baseSvgBeforeText2, second, baseSvgBeforeText3));
    finalSvg = string(abi.encodePacked(finalSvg, third, baseSvgEnd));

    // string memory finalSvg = string(abi.encodePacked(baseSvgBeforeText1, first, baseSvgBeforeText2, second, baseSvgBeforeText3, third, baseSvgEnd));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );



    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
  
    // We'll be setting the tokenURI later!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    // And we let the world know (through an event) that a new NFT has been minted!
    emit NewEpicNFTMinted(msg.sender, newItemId, NFT_MAX_LIMIT - firstWords.length);
  }
}
