import {Carousel} from 'react-bootstrap'
import image1 from './welcome1.png'
import image2 from './welcome2.png'
import image3 from './welcome3.png'

const Welcome = () =>{ return(
    <Carousel>
      <Carousel.Item>
        <img width={900} height={500} src={image1}/>
        <Carousel.Caption>
          <h3>Welcome to CSGO NFT Market!</h3>
          <p>Please click "connect wallet" to start.</p>
        </Carousel.Caption>
      </Carousel.Item>
      <Carousel.Item>
        <img width={900} height={500} alt="900x500" src={image2}/>
        <Carousel.Caption>
          <h3>NAVI are the champions of the PGL Major Stockholm 2021!</h3>
          <p>NAVI won the championship of PGL Major Stockholm 2021 with a 2 : 0 victory over G2 Esports in the grand final, earning $1,000,000 for their performance!</p>
        </Carousel.Caption>
      </Carousel.Item>
      <Carousel.Item>
        <img width={900} height={500} alt="900x500" src={image3}/>
        <Carousel.Caption>
          <h3>PGL Major Antwerp 2022</h3>
          <p>The first CS:GO Major of 2022, the PGL Major Antwerp, is nearing. Twenty-four teams from all over the world will compete for $1 million in prize money and the title of Major champions.</p>
        </Carousel.Caption>
      </Carousel.Item>
    </Carousel>
  )};
  
  export default Welcome;