import PieceTile from '../../src/components/PieceTile';

describe('PieceTile', () =>{
  let wrapper;
  beforeEach(()=> {
    jasmineEnzyme();

    wrapper = mount(
      <PieceTile
        piece = "R"
      />
    )
  })

  // it('should render div tag', () => {
  // 
  //   expect(wrapper.find('div.redpiece')).toBePresent()
  //   // expect(wrapper.find('p').text()).toBe("R")
  // })
})
