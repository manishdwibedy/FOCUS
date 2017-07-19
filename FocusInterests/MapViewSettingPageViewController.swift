//
//  MapViewSettingPageViewController.swift
//  FocusInterests
//
//  Created by Alex Jang on 7/18/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class MapViewSettingPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource{

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.mapSettingsVC(viewController: "MapSettingsOneViewController"),
                self.mapSettingsVC(viewController: "MapSettingsTwoViewController")]
    }()
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
//        setupPageControl()
        
        print(self.view.subviews[0].subviews[2].subviews)
        
        setViewControllers([orderedViewControllers.first!],direction: .forward,animated: true,completion: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let scrollView = view.subviews.filter({ $0 is UIScrollView }).first,
            let pageControl = view.subviews.filter({ $0 is UIPageControl }).first {
            let control = pageControl as! UIPageControl
            control.tintColor = UIColor.black
            control.pageIndicatorTintColor = UIColor.gray
            control.currentPageIndicatorTintColor = UIColor(red: 122/255.0, green: 201/255.0, blue: 1/255.0, alpha: 1.0)
            scrollView.frame = view.bounds
            view.bringSubview(toFront:control)
        }
    }
    
    func setupPageControl(){
        pageControl = UIPageControl(frame: CGRect(x: self.view.center.x,y: self.view.bounds.maxY-50,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
    }
    
    func mapSettingsVC(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(viewController)")
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        let viewControllerIndex = orderedViewControllers.index(of: viewController)
        
        if viewControllerIndex == 1 {
            return orderedViewControllers[0]
        }
        
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        let viewControllerIndex = orderedViewControllers.index(of: viewController)
        
        if viewControllerIndex == 0 {
            return orderedViewControllers[1]
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
